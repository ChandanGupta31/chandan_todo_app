import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo/domain/usecases/add_task_usecase.dart';
import 'package:todo/domain/usecases/delete_task_usecase.dart';
import 'package:todo/domain/usecases/get_tasks_usecase.dart';
import 'package:todo/domain/usecases/update_task_usecase.dart';
import 'package:todo/presentation/bloc/task_bloc.dart';
import 'package:todo/presentation/bloc/task_event.dart';
import 'package:todo/presentation/bloc/task_state.dart';

// Create Mock classes using Mocktail
class MockGetTasksUseCase extends Mock implements GetTasksUseCase {}
class MockAddTaskUseCase extends Mock implements AddTaskUseCase {}
class MockUpdateTaskUseCase extends Mock implements UpdateTaskUseCase {}
class MockDeleteTaskUseCase extends Mock implements DeleteTaskUseCase {}

void main() {
  // Declare variables for the BLoC and its mocked dependencies
  late MockGetTasksUseCase mockGetTasksUseCase;
  late MockAddTaskUseCase mockAddTaskUseCase;
  late MockUpdateTaskUseCase mockUpdateTaskUseCase;
  late MockDeleteTaskUseCase mockDeleteTaskUseCase;
  late TaskBloc taskBloc;

  // setUp runs automatically before EVERY single test case. 
  // It gives us a fresh, clean environment.
  setUp(() {
    mockGetTasksUseCase = MockGetTasksUseCase();
    mockAddTaskUseCase = MockAddTaskUseCase();
    mockUpdateTaskUseCase = MockUpdateTaskUseCase();
    mockDeleteTaskUseCase = MockDeleteTaskUseCase();

    taskBloc = TaskBloc(
      getTasksUseCase: mockGetTasksUseCase,
      addTaskUseCase: mockAddTaskUseCase,
      updateTaskUseCase: mockUpdateTaskUseCase,
      deleteTaskUseCase: mockDeleteTaskUseCase,
    );
  });

  // tearDown runs automatically after EVERY test case to clean up memory leaks.
  tearDown(() {
    taskBloc.close();
  });

  // TEST 1: Verify the baseline starting state
  test('Initial state of TaskBloc should be TaskInitial', () {
    expect(taskBloc.state, equals(TaskInitial()));
  });

  // TEST 2: Verify the stream of states when loading data succeeds
  blocTest<TaskBloc, TaskState>(
    'Emits [TaskLoading, TaskLoaded] when LoadTasksEvent is triggered successfully',
    build: () {
      // "When the mock is called, answer with an empty list instead of hit database"
      when(() => mockGetTasksUseCase.call()).thenAnswer((_) async => []);
      return taskBloc;
    },
    act: (bloc) => bloc.add(LoadTasksEvent()),
    expect: () => [
      TaskLoading(),
      const TaskLoaded(tasks: []),
    ],
  );
}