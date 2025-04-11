# Generate Tasks Data

100.times do |i|
  Task.create(
    title: "Task #{i + 1}",
    description: "Description for Task #{i + 1}",
    sequence: i + 1
  )
end