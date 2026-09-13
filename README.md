# Neurogine Catalog App

A responsive Flutter product catalog powered by the [DummyJSON Products API](https://dummyjson.com/docs/products). The app supports paginated browsing, debounced server-side search, pull-to-refresh, and product details with swipeable images.

The Flutter package is named `neurogine_catalog_app`; the app displays the title **Product Catalog**.

## Features

- Browse products with their title, thumbnail, and price
- Load additional pages automatically near the end of the catalog
- Search the full catalog through the server with a 350 ms debounce
- Refresh the active catalog or search results with pull-to-refresh
- Open a product detail screen that fetches current data by product ID
- View each product's description, price, and rating
- Swipe through product images and see the current image position
- Retry initial, pagination, and detail requests after an error
- See distinct loading, refreshing, empty, success, and error states
- Use responsive layouts that adapt to screen width and text scaling
- Use accessible controls, status announcements, image labels, and reduced-motion loading states

## Requirements

- Flutter SDK bundling Dart `>=3.12.0 <4.0.0`, matching `pubspec.yaml`
- An Android emulator, iOS simulator, or supported physical device
- The platform development tools for your target (Android SDK for Android; macOS and Xcode for iOS)
- Internet access for requests to `dummyjson.com`

## Setup

Clone the repository and install its dependencies:

```sh
git clone https://github.com/adamsyar/neurogine_catalog_app.git
cd neurogine_catalog_app
flutter pub get
```

If you already have the project checked out, run `flutter pub get` from its root directory. No API key or environment file is required. This repository includes Android and iOS platform projects.

Run the app on an available device:

```sh
flutter run
```

To select a particular device:

```sh
flutter devices
flutter run -d <device-id>
```

## Dependencies

- `flutter_bloc` manages the catalog and product-detail state
- `http` performs DummyJSON requests
- `skeletonizer` renders loading placeholders

## Architecture

The project uses a small feature-based structure with separate data and presentation layers:

```text
lib/
├── main.dart
├── app.dart
└── features/
    └── products/
        ├── data/
        │   ├── product.dart
        │   ├── product_page.dart
        │   ├── product_api_client.dart
        │   └── product_api_exception.dart
        └── presentation/
            ├── catalog/
            │   ├── bloc/
            │   └── catalog widgets
            ├── detail/
            │   ├── bloc/
            │   └── detail widgets
            └── widgets/
                └── shared product widgets
```

`ProductApiClient` owns the HTTP and JSON handling. `CatalogBloc` coordinates catalog loading, pagination, search, and refresh. `ProductDetailBloc` independently loads a selected product by ID. Widgets render the resulting states and send user actions back to their corresponding BLoCs.

The app injects one `ProductApiClient` at its root so the catalog and detail flows share the same configured client. The app closes that client when the root widget is disposed.

## API usage

The app uses these DummyJSON endpoints:

```text
GET /products?limit=20&skip=<offset>
GET /products/search?q=<query>&limit=20&skip=<offset>
GET /products/<id>
```

Catalog and search requests use pages of 20 products. Each successful page advances `skip` by the number of products returned. Pagination stops when the next offset reaches the API total or the API returns no products. Products are deduplicated by ID when pages are loaded.

Search is performed on the server so results cover the full DummyJSON catalog instead of only products already loaded on the device. Queries are trimmed before use and debounced for 350 ms. Changing the input immediately invalidates older work, preventing delayed responses from replacing results for the latest query.

Pull-to-refresh reloads the first page for the active normalized query. If refresh fails, existing products remain visible and a snackbar shows the error. A pagination failure also retains existing products and displays a footer retry action.

API requests have a 15-second timeout. The client maps connection failures, unsuccessful HTTP responses, and unreadable response data to user-facing error messages.

## UI and accessibility

The interface uses a warm off-white background, white rounded cards, and a muted green accent. The catalog becomes a multi-column layout when sufficient width is available and returns to a single column when screen width or text scaling requires more room.

Loading and result changes use semantic live regions. Product cards, images, retry controls, ratings, and gallery position provide descriptive semantics. Skeleton loading remains static when reduced motion or accessible navigation is enabled.

## AI assistance

AI assistance was used to help write the automated test files and this README.

## Verification

Format, analyze, and run the test suite with:

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

The existing unit tests cover:

- `ProductApiClient`: catalog parsing, normalized search requests, and HTTP error handling
- `CatalogBloc`: initial loading and retry, pagination, search debounce and stale responses, clearing search, and refreshing an active query
- `ProductDetailBloc`: loading by product ID and retrying a failed request

Tests use a mock HTTP client or a fake API client and do not require the live DummyJSON service.
