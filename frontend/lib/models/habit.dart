class Task {
  final String id;
  final String task;
   bool isCompleted;

  Task({required this.id, required this.task, required this.isCompleted});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString(),//convert to string
      task: json['task'],
      isCompleted: json['isCompleted']?? false,
    );
  }
  
  ///////////////////////////////////////
  Map<String, dynamic> toJson() => {
    'id': id,
    'task': task,
    'isCompleted': isCompleted,
  };
  ///////////////////////////////////
}

class Habit {
  final String id;
  final String name;
  final String type;
  final List<Task> tasks;

  Habit({required this.id, required this.name, required this.type, required this.tasks});

  factory Habit.fromJson(Map<String, dynamic> json) {
    var tasksFromJson = json['tasks'] as List;
    List<Task> taskList = tasksFromJson.map((t) => Task.fromJson(t)).toList();

    return Habit(
      id: json['id'].toString(),
      name: json['name'],
      type: json['type'],
      tasks: taskList,
    );
  }
  //////////////////////////////////////////////////////
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'tasks': tasks.map((task) => task.toJson()).toList(),
  };
  //////////////////////////////////////////////////////
}
