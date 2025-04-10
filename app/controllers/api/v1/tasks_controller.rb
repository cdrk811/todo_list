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
          # Update the tasks that were moved (dragged and dropped)
          tasks_to_update.each do |task_data|
            task = Task.find(task_data[:id])
            next if task.update(sequence: task_data[:sequence])

            raise ActiveRecord::Rollback, "Failed to update task with ID #{task.id}"
          end

          # Reorder the remaining tasks (those not included in the drag-and-drop)
          remaining_tasks = Task.where.not(id: updated_tasks_ids)

          remaining_tasks.each_with_index do |task, index|
            new_sequence = tasks_to_update.size + index + 1
            next if task.update(sequence: new_sequence)

            raise ActiveRecord::Rollback, "Failed to update task with ID #{task.id}"
          end
        end

        updated_tasks = Task.where(id: updated_tasks_ids)

        render_success_json(updated_tasks)
      rescue ActiveRecord::Rollback => e
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
