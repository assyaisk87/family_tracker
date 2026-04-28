# Family Tracker - Реализованные возможности

## Обзор проекта

Family Tracker - это Flutter приложение для управления семейными задачами с использованием Supabase как бэкенда. Приложение реализует чистую архитектуру (Clean Architecture) с использованием Bloc/Cubit паттерна для управления состоянием.

---

## 📋 Реализованные функции

### 1. Управление задачами (Task Management)

#### 1.1 Структура задач
- **Модель Task** содержит:
  - `id` (bigint) - уникальный идентификатор
  - `title` (String) - название задачи
  - `description` (String) - описание
  - `completed` (bool) - статус выполнения
  - `priority` (bool) - флаг приоритета (высокий приоритет = true)
  - `dueDate` (DateTime?) - дата срока выполнения
  - `createdAt` (DateTime) - дата создания
  - `assignees` (List<FamilyUser>) - список назначенных пользователей
  - `createdBy` (String) - идентификатор создателя задачи

#### 1.2 Фильтрация и сортировка задач

**Доступные фильтры:**
- `all` - все задачи
- `completed` - завершенные задачи
- `pending` - незавершенные задачи
- `highPriority` - задачи с высоким приоритетом
- `myTasks` - только задачи текущего пользователя (по createdBy или assignees)

**Доступные сортировки:**
- `byCreatedDate` - по дате создания
- `byDueDate` - по дате срока выполнения (с обработкой null значений и незавершенных задач)

**Реализация фильтрации:**
```dart
// TaskCubit._applyFiltersAndSorting()
// Применяет выбранные фильтры и сортировку к списку задач
// Фильтры могут комбинироваться
// "Мои задачи" фильтр сравнивает task.createdBy и task.assignees с currentUserId
```

**UI Компоненты:**
- 3 выпадающих меню в TaskListScreen для выбора сортировки, фильтра и дополнительного фильтра по исполнителю
- Кнопка "Сброс" для очистки всех фильтров
- Сообщение "Нет задач по выбранным фильтрам" при пустом списке после применения фильтров

#### 1.3 Визуальные индикаторы задач

**Индикатор приоритета:**
- Красная иконка в верхнем левом углу карточки задачи (если `priority == true`)
- Иконка отображается в Stack layout поверх основной карточки

**Просроченные задачи:**
- Заголовок задачи отображается красным цветом, если:
  - Задача не завершена (`completed == false`)
  - Дата срока в прошлом (`dueDate.isBefore(DateTime.now())`)
- Логика реализована в `TaskCard.isOverdue` геттере

**Карточка задачи (TaskCard):**
```
┌─────────────────────────────┐
│ 🚩 Название задачи           │ <- приоритет значок
│ Описание                      │
│ ➤ Иван, Мария               │ <- исполнители
│ 📅 выполнить к 30.04        │ <- дата срока
└─────────────────────────────┘
```

---

### 2. Управление профилем (Profile Management)

#### 2.1 ProfileCubit - бизнес логика профиля

**Файл:** `lib/presentation/cubit/profile_cubit.dart`

**Функциональность:**
- `loadProfile()` - загружает данные профиля пользователя
  - Получает AuthUser через AuthRepository.getCurrentUserWithFamily()
  - Извлекает список членов семьи через FamilyUsersRepository.getFamilyUsers()
  - Строит домен-модель User на основе AuthUser с добавлением email
  - Отслеживает текущего пользователя и его роль (parent/child)
  - Отслеживает, является ли текущий пользователь родителем (currentUserIsParent)

- `signOut()` - выход из аккаунта
  - Обработка ошибок через try/catch
  - Эмиссия состояния ошибки при выходе
  - Очистка состояния профиля
  - Сброс к начальному состоянию

**Зависимости:**
- AuthRepository - для получения данных пользователя
- FamilyUsersRepository - для получения списка членов семьи

#### 2.2 ProfileState - состояние профиля

**Файл:** `lib/presentation/cubit/profile_state.dart`

**Freezed Model:**
```dart
enum ProfileStatus { initial, loading, loaded, error }

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default(ProfileStatus.initial) ProfileStatus status,
    User? user,
    @Default([]) List<FamilyUser> familyMembers,
    String? currentUserId,
    @Default(false) bool currentUserIsParent,
    String? errorMessage,
  }) = _ProfileState;
}
```

**Статусы:**
- `initial` - начальное состояние
- `loading` - загрузка профиля
- `loaded` - профиль успешно загружен
- `error` - ошибка при загрузке

#### 2.3 ProfileScreen - экран профиля

**Файл:** `lib/presentation/screens/profile_screen.dart`

**Структура экрана:**
1. **AppBar** - заголовок с кнопкой выхода (logout)
   - Кнопка выхода выполняет:
     - Вызов `context.read<ProfileCubit>().signOut()`
     - Навигацию на первый экран при успехе (popUntil)
     - Отображение SnackBar при ошибке

2. **BlocBuilder** - реагирует на изменения состояния:
   - Loading - показывает CircularProgressIndicator
   - Error - показывает сообщение об ошибке
   - Loaded - показывает профиль пользователя

3. **Содержимое профиля:**
   - Информация о пользователе (имя, аватар)
   - Список членов семьи (FamilyUsersSection)

**Важный паттерн:**
```dart
BlocProvider(
  create: (_) => ProfileCubit(...)..loadProfile(),
  child: Builder(
    builder: (context) => Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              try {
                await context.read<ProfileCubit>().signOut();
                // навигация
              } catch (e) {
                // ошибка
              }
            },
          )
        ],
      ),
    ),
  ),
)
```

**Критически важно:** Scaffold обёрнут в Builder для того чтобы `context.read<ProfileCubit>()` имел доступ к провайдеру. Без этого возникает ошибка "Could not find the correct Provider<ProfileCubit>".

#### 2.4 FamilyUsersSection - раздел членов семьи

**Файл:** `lib/presentation/widgets/family_users_section.dart`

**Функциональность:**
- Отображает список членов семьи с их данными:
  - Имя (displayName)
  - Роль (parent/child)
  - Аватар (avatarUrl)

- Каждый член семьи может быть отредактирован (диалог редактирования)
  - Изменение имени
  - Изменение роли

**Паттерн:**
- Синхронный виджет (не использует Future.when)
- Принимает `List<FamilyUser>` непосредственно от родителя (ProfileCubit)
- Каждый пользователь отображается в ListTile с возможностью редактирования

---

### 3. Модели данных (Data Models)

#### 3.1 User (Домен-сущность)
**Файл:** `lib/domain/entities/user.dart`

```dart
class User {
  final String id;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final int postsCount;
  final String familyId;  // <- добавлено для поддержки работы с профилем
  final String? email;     // <- добавлено для отображения email
}
```

#### 3.2 AuthUser (Модель аутентификации)
**Из AuthRepository:**
```dart
class AuthUser {
  final String id;
  final String email;
  final String? familyId;  // <- для идентификации семьи пользователя
  final String? displayName;
  final String? avatarUrl;
}
```

#### 3.3 FamilyUser (Сущность члена семьи)
**Файл:** `lib/domain/entities/family_user.dart`

```dart
class FamilyUser {
  final String id;
  final String userId;
  final String familyId;
  final String role;          // 'parent' или 'child'
  final String displayName;
  final String? avatarUrl;
}
```

#### 3.4 Task (Модель задачи)
**Файл:** `lib/domain/entities/task.dart`

```dart
class Task {
  final int id;
  final String title;
  final String description;
  final bool completed;
  final bool priority;        // <- упрощенный флаг вместо таблицы priority
  final DateTime? dueDate;
  final DateTime createdAt;
  final List<FamilyUser> assignees;
  final String createdBy;     // <- для фильтра "Мои задачи"
}
```

---

### 4. Управление состоянием (State Management)

#### 4.1 TaskCubit

**Файл:** `lib/presentation/cubit/task_cubit.dart`

**Состояние:**
```dart
enum TaskSortBy { byCreatedDate, byDueDate }
enum TaskFilter { all, completed, pending, highPriority, myTasks }

class TaskState {
  final List<Task> tasks;
  final List<Task> filteredTasks;
  final TaskSortBy sortBy;
  final TaskFilter filter;
  final String? assigneeFilter;
  final String? currentUserId;  // <- для фильтра "Мои задачи"
  // ...
}
```

**Основные методы:**
- `loadTasks()` - загружает список задач
- `updateSortBy(TaskSortBy)` - изменяет сортировку
- `updateFilter(TaskFilter)` - изменяет фильтр
- `updateAssigneeFilter(String?)` - изменяет фильтр по исполнителю
- `setCurrentUserId(String)` - устанавливает ID текущего пользователя
- `_applyFiltersAndSorting()` - применяет все фильтры и сортировку

**Логика фильтрации "Мои задачи":**
```dart
if (filter == TaskFilter.myTasks) {
  tasks = tasks.where((task) {
    return task.createdBy == currentUserId ||
           task.assignees.any((assignee) => assignee.userId == currentUserId);
  }).toList();
}
```

---

### 5. Слой данных (Data Layer)

#### 5.1 FamilyUsersRepository

**Интерфейс:** `lib/domain/repositories/family_users_repository.dart`
```dart
abstract class FamilyUsersRepository {
  Future<List<FamilyUser>> getFamilyUsers(String familyId);
}
```

**Реализация:** `lib/data/repositories/family_users_repository_impl.dart`
- Использует FamilyUsersRemoteDataSource для получения данных
- Преобразует модели в домен-сущности

#### 5.2 FamilyUsersRemoteDataSource

**Файл:** `lib/data/datasources/family_users_remote_data_source.dart`
- Получает список членов семьи из Supabase
- Возвращает `List<FamilyUserModel>`

---

### 6. Инъекция зависимостей (Dependency Injection)

**Файл:** `lib/locator.dart`

**Зарегистрированные компоненты:**
```dart
// Repositories
getIt.registerSingleton<AuthRepository>(AuthRepositoryImpl(...));
getIt.registerSingleton<TaskRepository>(TaskRepositoryImpl(...));
getIt.registerSingleton<FamilyUsersRepository>(
  FamilyUsersRepositoryImpl(...),
);

// Data Sources
getIt.registerSingleton<FamilyUsersRemoteDataSource>(
  FamilyUsersRemoteDataSource(...),
);

// Cubits
getIt.registerLazySingleton<TaskCubit>(...);
getIt.registerLazySingleton<ProfileCubit>(...);
```

---

### 7. Обработка ошибок (Error Handling)

#### 7.1 ProfileCubit.signOut()
```dart
Future<void> signOut() async {
  try {
    await _authRepository.signOut();
    emit(const ProfileState());
  } catch (e) {
    emit(state.copyWith(
      status: ProfileStatus.error,
      errorMessage: 'Ошибка при выходе: $e',
    ));
    rethrow;  // <- переброс для UI обработки
  }
}
```

#### 7.2 ProfileScreen - обработка signOut
```dart
IconButton(
  onPressed: () async {
    try {
      await context.read<ProfileCubit>().signOut();
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${e.toString()}')),
      );
    }
  },
  icon: const Icon(Icons.logout),
)
```

---

## 🏗️ Архитектура приложения

### Слои Clean Architecture:

```
┌─────────────────────────────────┐
│     Presentation Layer          │
│  (Screens, Widgets, Cubits)     │
└──────────────┬──────────────────┘
               │
┌──────────────▼──────────────────┐
│     Domain Layer                │
│  (Entities, Repositories)       │
└──────────────┬──────────────────┘
               │
┌──────────────▼──────────────────┐
│     Data Layer                  │
│  (Repositories, DataSources)    │
└──────────────┬──────────────────┘
               │
┌──────────────▼──────────────────┐
│     External Layer              │
│  (Supabase, External APIs)      │
└─────────────────────────────────┘
```

### Паттерны:

- **BLoC Pattern** - использование Cubit для управления состоянием
- **Repository Pattern** - абстракция доступа к данным
- **Dependency Injection** - управление зависимостями через GetIt
- **Freezed** - код генерация для неизменяемых классов состояния

---

## 📱 Файловая структура

```
lib/
├── main.dart                          # Точка входа
├── locator.dart                       # Инъекция зависимости
├── domain/
│   ├── entities/
│   │   ├── user.dart                 # Модель пользователя
│   │   ├── task.dart                 # Модель задачи
│   │   ├── family_user.dart          # Модель члена семьи
│   │   └── auth_user.dart            # Модель аутентификации
│   └── repositories/
│       ├── auth_repository.dart
│       ├── task_repository.dart
│       └── family_users_repository.dart
├── data/
│   ├── datasources/
│   │   ├── family_users_remote_data_source.dart
│   │   └── task_remote_data_source.dart
│   ├── models/
│   │   ├── family_user_model.dart
│   │   └── task_model.dart
│   └── repositories/
│       ├── auth_repository_impl.dart
│       ├── task_repository_impl.dart
│       └── family_users_repository_impl.dart
└── presentation/
    ├── cubit/
    │   ├── task_cubit.dart            # Управление задачами
    │   ├── task_state.dart            # Состояние задач
    │   ├── profile_cubit.dart         # Управление профилем
    │   └── profile_state.dart         # Состояние профиля
    ├── screens/
    │   ├── task_list_screen.dart      # Экран списка задач
    │   ├── profile_screen.dart        # Экран профиля
    │   └── ...
    └── widgets/
        ├── task_card.dart            # Карточка задачи
        ├── family_users_section.dart  # Раздел членов семьи
        └── ...
```

---

## 🔄 Основные потоки выполнения

### Загрузка списка задач:
1. TaskListScreen вызывает `TaskCubit.loadTasks()`
2. TaskCubit получает данные через TaskRepository
3. TaskRepository обращается к TaskRemoteDataSource (Supabase)
4. Данные преобразуются в Task entities
5. TaskCubit применяет фильтры и сортировку
6. UI обновляется через BlocBuilder

### Загрузка профиля:
1. ProfileScreen создает ProfileCubit через BlocProvider
2. ProfileCubit вызывает `loadProfile()`
3. Получает AuthUser через AuthRepository
4. Получает список членов семьи через FamilyUsersRepository
5. Строит User domain entity
6. Emits ProfileState с статусом loaded
7. UI обновляется через BlocBuilder

### Выход из аккаунта:
1. UserProfile нажимает кнопку logout
2. Вызывается `ProfileCubit.signOut()`
3. AuthRepository выполняет signOut операцию
4. State обновляется (error или normal состояние)
5. UI показывает SnackBar при ошибке
6. Навигация к первому экрану при успехе

---

## 🛠️ Технологический стек

- **Framework:** Flutter
- **Language:** Dart
- **State Management:** Bloc/Cubit (flutter_bloc)
- **Backend:** Supabase
- **Code Generation:** Freezed for immutable models
- **Dependency Injection:** GetIt
- **Image Handling:** image_picker

---

## 📝 Сводка реализованного функционала

✅ **Управление задачами:**
- Загрузка и отображение задач
- Фильтрация по статусу (завершенные/незавершенные)
- Фильтрация по приоритету
- Фильтрация "Мои задачи" (по создателю или исполнителю)
- Сортировка по дате создания и сроку выполнения
- Визуальные индикаторы (приоритет, просрочка)

✅ **Управление профилем:**
- Загрузка профиля пользователя
- Отображение списка членов семьи
- Выход из аккаунта с обработкой ошибок
- Диалоги редактирования профиля членов семьи
- Отслеживание роли пользователя (parent/child)

✅ **Архитектура:**
- Чистая архитектура (Clean Architecture)
- Разделение на слои (Domain, Data, Presentation)
- Управление состоянием через Cubit/BLoC
- Инъекция зависимостей через GetIt
- Обработка ошибок на уровне Cubit и UI

✅ **Интеграция с Supabase:**
- Аутентификация пользователей
- Получение задач из БД
- Получение информации о членах семьи
- Преобразование моделей БД в домен-сущности

---

## Планируемый функционал

Профиль:
- Редактирование членов семьи
- Загрузка аватара (изображение)

Календарь
- Отображение календаря

Задачи:
- Видимость задач по ролям (родитель/ребенок)
- Редактирование/удаление
- Валидация

## 🚀 Возможные улучшения и TODO

- [ ] Сохранение изменений профиля в Supabase
- [ ] Загрузка аватара через image_picker
- [ ] Локализация на несколько языков
- [ ] Добавление новых задач
- [ ] Редактирование и удаление задач
- [ ] Push уведомления о предстоящих задачах
- [ ] Offline режим
- [ ] Тестирование (Unit tests, Widget tests) 

---

*Последнее обновление: 28 апреля 2026*
