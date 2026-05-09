# sufar_project

A new Flutter project.

## Seed real hotel images (MongoDB)

If hotels/rooms images are not showing, it usually means Mongo documents have an empty `images: []` array.
Run the provided seeding script once to populate `hotels.images` with real image URLs (from Pexels).

### 1) Set environment variables (PowerShell)

From `d:\4th Year\sufar\sufar_project`:

```powershell
$env:MONGO_URI="mongodb+srv://..."; 
$env:PEXELS_API_KEY="..."; 
node .\seed_hotel_images.js
```

Do **not** hardcode secrets in code. Use `.env.example` as a template for what variables are needed.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
