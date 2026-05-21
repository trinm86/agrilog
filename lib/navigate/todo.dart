class Todo {
  final String title;
  final String description;

  Todo(this.title, this.description);
}

final todos = List<Todo>.generate(
  20,
  (i) => Todo(
        'Todo ${i+1}',
        'A description of what needs to be done for Todo ${i+1}.',
      ),
);