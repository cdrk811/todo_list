# frozen_string_literal: true

module Api
  module V1
    class TasksController < ApiController
      before_action :set_task, only: %i[update destroy]

      # GET /api/v1/tasks
      def index
        @tasks = Task.all

        render_success_json(@tasks)
      end

      # POST /api/v1/tasks
      def create
        @task = Task.new(task_params)

        if @task.save
          render_success_json(@task)
        else
          render json: { status: 422, success: false, errors: @task.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PUT/PATCH /api/v1/tasks/:id
      def update
        if @task.update(task_params)
          render_success_json(@task)
        else
          render json: { status: 422, success: false, errors: @task.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/tasks/:id
      def destroy
        if @task.destroy
          render_success_json(@task)
        else
          render json: { status: 422, success: false, errors: @task.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH  /api/v1/tasks/reorder
      def reorder
        return render json: { success: false, message: "No tasks provided." }, status: :unprocessable_entity if params[:tasks].blank?

        tasks_to_update = params[:tasks]
        updated_tasks_ids = tasks_to_update.map { |task_data| task_data[:id] }

        ActiveRecord::Base.transaction do
          # Update the tasks that were moved (dragged and dropped) using CASE statement
          update_tasks_sql = "UPDATE tasks AS t SET sequence = CASE "
          tasks_to_update.each do |task_data|
            update_tasks_sql += "WHEN t.id = #{task_data[:id]} THEN #{task_data[:sequence]} "
          end
          update_tasks_sql += "END WHERE t.id IN (#{updated_tasks_ids.join(', ')})"

          ActiveRecord::Base.connection.execute(update_tasks_sql)

          # Reorder the remaining tasks (those not included in the drag-and-drop) using CASE statement
          remaining_tasks = Task.where.not(id: updated_tasks_ids).order(:id)
          base_sequence = tasks_to_update.size + 1

          remaining_tasks_sql = "UPDATE tasks AS t SET sequence = CASE "
          remaining_tasks.each_with_index do |task, index|
            remaining_tasks_sql += "WHEN t.id = #{task.id} THEN #{base_sequence + index} "
          end
          remaining_tasks_sql += "END WHERE t.id IN (#{remaining_tasks.pluck(:id).join(', ')})"

          ActiveRecord::Base.connection.execute(remaining_tasks_sql)
        end

        updated_tasks = Task.where(id: updated_tasks_ids)
        render_success_json(updated_tasks)
      rescue => e
        render json: { success: false, message: e.message }, status: :unprocessable_entity
      end

      private

      def set_task
        @task = Task.find params[:id]
      end

      def task_params
        params.require(:task).permit(:title, :description)
      end
    end
  end
end
