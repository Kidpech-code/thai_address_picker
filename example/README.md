# Thai Address Picker - Examples

ตัวอย่างการใช้งาน thai_address_picker แพ็คเกจ รวมถึง integration กับ state management ต่างๆ

## 📂 Example Files

### 🎯 Scenario-Based Examples

#### 1. **complete_integration_example.dart** ⭐ (แนะนำให้เริ่มต้นจากที่นี่)

- **สำหรับ:** ผู้ที่ต้องการเห็นทั้งหมด
- **ตัวอย่าง:**
  - ใช้ `ThaiAddressForm`
  - ใช้ `ZipCodeAutocomplete`
  - ใช้ `VillageAutocomplete`
  - การแสดงผลสรุป
- **พิเศษ:** Wizard-style (Step-by-step) UI
- **Code:** ~400 lines

#### 2. **provider_integration_example.dart**

- **Scenario:** 3 - ใช้ร่วมกับ Provider
- **สำหรับ:** โปรเจคที่ใช้ `provider` package
- **ตัวอย่าง:**
  - Wrap ด้วย `ProviderScope` + `MultiProvider`
  - ใช้ `Consumer` widget
  - ChangeNotifier state management
- **Code:** ~300 lines
- **Run:**
  ```bash
  flutter run
  # จากนั้นเลือก "Provider Integration"
  ```

#### 3. **repository_only_example.dart**

- **Scenario:** 2 - ไม่ต้อง ProviderScope
- **สำหรับ:** โปรเจคที่ใช้ state management อื่น (BLoC, GetX, Redux, etc.)
- **ตัวอย่าง:**
  - สร้าง Repository เอง
  - จัดการ state ด้วย `setState`
  - Custom UI ด้วย DropdownButton
  - Cascading dropdowns
- **Code:** ~350 lines
- **Key Point:** ไม่ใช้ ProviderScope ❌

#### 4. **getx_integration_example.dart**

- **Scenario:** 3 - ใช้ร่วมกับ GetX
- **สำหรับ:** โปรเจค GetX
- **ตัวอย่าง:**
  - GetX Controller
  - Obx() widget
  - Observable variables
  - Get.snackbar()
- **Code:** ~350 lines
- **Note:** สำหรับการใช้จริง ต้องเพิ่ม `get` ใน pubspec.yaml

### ✨ Feature-Based Examples

#### 5. **custom_ui_example.dart**

- **Feature:** Custom UI ของคุณเอง
- **สำหรับ:** การใช้ repository โดยตรง
- **ตัวอย่าง:**
  - Custom DropdownButton
  - Cascading selection
  - Real-time filtering
- **Code:** ~200 lines

#### 6. **zip_code_autocomplete_example.dart**

- **Feature:** Zip Code Autocomplete
- **สำหรับ:** Reverse lookup (Zip → Address)
- **ตัวอย่าง:**
  - ค้นหาจากรหัสไปรษณีย์
  - Auto-fill all fields
  - Handle multiple areas
- **Code:** ~150 lines

#### 7. **village_autocomplete_example.dart**

- **Feature:** Village Autocomplete
- **สำหรับ:** ค้นหาหมู่บ้าน
- **ตัวอย่าง:**
  - Real-time search
  - Moo number display
  - ~70,000 villages
- **Code:** ~150 lines

#### 8. **zip_code_lookup_example.dart**

- **Feature:** Zip Code Lookup
- **สำหรับ:** กรอกรหัส เติมที่อยู่อัตโนมัติ
- **ตัวอย่าง:**
  - TextField กรอกรหัส
  - Auto-selection
  - Error handling
- **Code:** ~150 lines

### 📱 main.dart

- **หน้าแรกของ example app**
- **ตัวอย่าง:**
  - Navigation ไปหา example ต่างๆ
  - Direct Form usage (Example 1)
  - Bottom Sheet Picker (Example 2)
  - Dialog Picker (Example 3)
  - Display selected address
- **Code:** ~300 lines

---

## 🚀 How to Run

### 1. Run Example App

```bash
cd example
flutter run
```

### 2. Navigate to Specific Example

- อ่านหน้าแรก
- แตะที่ example ที่ต้องการ

### 3. ดูโค้ด

```bash
# เปิด lib/complete_integration_example.dart
# หรือ example ที่ต้องการ
```

---

## 📊 Scenario Comparison

| File                       | Scenario | ต้อง ProviderScope? | State Management | Use Case                   |
| -------------------------- | -------- | ------------------- | ---------------- | -------------------------- |
| complete_integration.dart  | 1        | ✅                  | Riverpod         | Learn all features         |
| provider_integration.dart  | 3        | ✅                  | Provider         | Existing Provider projects |
| repository_only.dart       | 2        | ❌                  | setState         | Other state mgmt           |
| getx_integration.dart      | 3        | ✅                  | GetX             | GetX projects              |
| custom_ui.dart             | 1        | ✅                  | Riverpod         | Custom UI design           |
| zip_code_autocomplete.dart | 1        | ✅                  | Riverpod         | Zip code feature           |
| village_autocomplete.dart  | 1        | ✅                  | Riverpod         | Village search             |
| zip_code_lookup.dart       | 1        | ✅                  | Riverpod         | Reverse lookup             |

---

## 💡 Learning Path (แนะนำลำดับการเรียน)

1. **เริ่มต้น:** `complete_integration_example.dart`

   - ดูทั้งหมดรวมกัน
   - Wizard-style UI ช่วยให้เข้าใจ

2. **Feature-specific:**

   - `custom_ui_example.dart` → Custom UI
   - `zip_code_autocomplete_example.dart` → Zip search
   - `village_autocomplete_example.dart` → Village search

3. **Integration:**
   - `provider_integration_example.dart` → ถ้าใช้ Provider
   - `repository_only_example.dart` → ถ้าใช้ state mgmt อื่น
   - `getx_integration_example.dart` → ถ้าใช้ GetX

---

## 🎯 Common Use Cases

### Use Case 1: "ผมใช้ Provider อยู่แล้ว"

**ดู:** `provider_integration_example.dart`

```dart
ProviderScope(
  child: MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AddressFormState()),
    ],
    child: const MyApp(),
  ),
)
```

### Use Case 2: "ผมใช้ GetX"

**ดู:** `getx_integration_example.dart`

```dart
ProviderScope(
  child: GetMaterialApp(
    home: const GetXIntegrationExample(),
  ),
)
```

### Use Case 3: "ผมไม่อยากใช้ ProviderScope"

**ดู:** `repository_only_example.dart`

```dart
// ไม่ต้อง ProviderScope
final repository = ThaiAddressRepository();
await repository.initialize();
```

### Use Case 4: "ผมต้องการ Custom UI"

**ดู:** `custom_ui_example.dart`

```dart
// ใช้ repository + custom widgets
final provinces = repository.provinces;
// สร้าง UI เอง
```

### Use Case 5: "ผมต้องการค้นหาจากรหัสไปรษณีย์"

**ดู:** `zip_code_autocomplete_example.dart`

```dart
ZipCodeAutocomplete(
  onZipCodeSelected: (zipCode) {
    // All fields auto-filled
  },
)
```

---

## 📝 Notes

- ทุก example ใช้ `ProviderScope` ยกเว้น `repository_only_example.dart`
- ทุก example มี Thai + English comments
- Code เขียนสะอาด easy to read
- ~2000 lines code รวมทั้งหมด

---

## 🔗 Related Documentation

- **README.md** - Documentation หลัก
- **IMPLEMENTATION_SUMMARY.md** - Implementation details
- **ZIP_CODE_AUTOCOMPLETE.md** - Zip code feature deep dive
- **USAGE.md** - Advanced usage guide

---

## ❓ FAQ

**Q: ตัวอย่างไหนที่ควรเห็นก่อน?**
A: `complete_integration_example.dart` ✨

**Q: ผมต้องการเขียน custom state management**
A: ดู `repository_only_example.dart`

**Q: ผมใช้ Provider/BLoC/GetX ต้องทำอะไร?**
A: ดู scenario 3 examples

**Q: ต้องเพิ่ม package อะไร?**
A: ไม่ต้อง (นอกเว้นถ้าอยากลองตัวจริง provider/getx)

---

Enjoy! 🚀 Happy Coding! 💚
