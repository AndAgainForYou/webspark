import 'dart:collection';

class Task {
  final String id;
  final List<String> field;
  final Point start;
  final Point end;
  late List<Point> steps;
  late String path;

  Task({required this.id, required this.field, required this.start, required this.end}) {
    steps = _calculateShortestPath();
    path = steps.map((point) => '(${point.x},${point.y})').join('->');
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      field: List<String>.from(json['field']),
      start: Point.fromJson(json['start']),
      end: Point.fromJson(json['end']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field': field,
      'start': start.toJson(),
      'end': end.toJson(),
    };
  }

  List<Point> _calculateShortestPath() {
    final List<List<int>> grid = field.map((row) {
      return row.split('').map((cell) => cell == 'X' ? 1 : 0).toList();
    }).toList();

    final int numRows = grid.length;
    final int numCols = grid[0].length;

    final Queue<List<Point>> queue = Queue();
    final Set<Point> visited = {};

    if (start.x < 0 || start.y < 0 || start.x >= numCols || start.y >= numRows ||
        end.x < 0 || end.y < 0 || end.x >= numCols || end.y >= numRows ||
        grid[start.y][start.x] == 1 || grid[end.y][end.x] == 1) {
      print('Invalid start or end position');
      return [];
    }

    print('Start: $start, End: $end');
    print('Grid:');
    for (var row in grid) {
      print(row);
    }

    queue.add([start]);
    visited.add(start);

    while (queue.isNotEmpty) {
      final List<Point> path = queue.removeFirst();
      final Point current = path.last;

      print('Current path: $path');
      print('Current position: $current');

      if (current == end) {
        print('Path found: $path');
        return path;
      }

      final List<Point> neighbors = [
        Point(x: current.x + 1, y: current.y),
        Point(x: current.x - 1, y: current.y),
        Point(x: current.x, y: current.y + 1),
        Point(x: current.x, y: current.y - 1),
      ];

      for (final neighbor in neighbors) {
        if (neighbor.x >= 0 &&
            neighbor.y >= 0 &&
            neighbor.x < numCols &&
            neighbor.y < numRows &&
            grid[neighbor.y][neighbor.x] == 0 &&
            !visited.contains(neighbor)) {
          visited.add(neighbor);
          queue.add([...path, neighbor]);
          print('Adding $neighbor to queue');
        }
      }
    }

    print('No path found');
    return [];
  }
}

class Point {
  final int x;
  final int y;

  Point({required this.x, required this.y});

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
      x: json['x'],
      y: json['y'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Point) return false;
    return other.x == x && other.y == y;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() => '($x, $y)';
}




class TaskResult {
  final String id;
  final bool correct;

  TaskResult({required this.id, required this.correct});

  factory TaskResult.fromJson(Map<String, dynamic> json) {
    return TaskResult(
      id: json['id'],
      correct: json['correct'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'correct': correct,
    };
  }
}
