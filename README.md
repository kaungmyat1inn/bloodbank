# သွေးလှူဒါန်းရေးအသင်း — Donor Management System

Flutter app (Web + Android, code တစ်ခုတည်း) — Firebase backend, Vercel မှာ web deploy၊ GitHub Actions ကနေ Android APK ကို auto-build လုပ်ပြီး web ထဲက "Android App Download" ခလုတ်နဲ့ ဒေါင်းလုတ်ရယူနိုင်အောင် ချိတ်ဆက်ထားပါတယ်။

## Features

- **အသစ်စာရင်းသွင်းမည်** — အဖွဲ့ဝင်အမှတ် (001 ကနေစ auto), အမည်၊ သွေးအမျိုးအစား၊ လိပ်စာ၊ ဖုန်း၊ Viber
- **သွေးလှူရှင်ပရိုဖိုင်** — အလှူရှင်စာရင်းအားလုံး + individual profile + သွေးလှူမှတ်တမ်းအပြည့်အစုံ
- **သွေးလှူနိုင်သောစာရင်း** — နောက်ဆုံးလှူသည့်ရက်မှ ၁၂၀ ရက်ကျော်သူ (သို့) တစ်ကြိမ်မှမလှူရသေးသူများ
- **သွေးလှူမှတ်တမ်း** — မှတ်တမ်းအားလုံး feed + "မှတ်တမ်းအသစ်ထည့်မည်" (အဖွဲ့ဝင်အမှတ်/အမည်ဖြင့်ရှာပြီး "သွေးလှူပြီးပါပြီ" နှိပ်ရုံ)
- **အလှူရှင်ရှာရန်** — သွေးအမျိုးအစားရွေးပြီး ယခုလှူနိုင်သူများကို ချက်ချင်းပြသ + ဖုန်းခေါ်ခလုတ်
- Responsive — desktop (sidebar) / mobile (drawer + bottom nav) layout နှစ်မျိုးလုံး
- Staff login (email/password) — public donor self-service မဟုတ်ပါ၊ admin/staff internal tool ဖြစ်ပါတယ်

## ⚠️ အရေးကြီးသောမှတ်ချက် (ဒီ code ကို ဘယ်လိုစစ်ဆေးခဲ့လဲ)

ဒီ session run နေတဲ့ sandbox environment မှာ network policy က Flutter SDK download (`storage.googleapis.com`) ကို block လုပ်ထားလို့ **`flutter analyze` / `flutter build` ကို ဒီနေရာမှာ အမှန်တကယ် run ပြီး စစ်ဆေးလို့မရခဲ့ပါ။** Code အားလုံးကို line-by-line ဂရုတစိုက်ရေးထား၊ syntax/brace balance ကို script နဲ့ double-check လုပ်ထားပေမယ့် — `flutter pub get` ပြီး local (သို့) GitHub Actions/Vercel မှာ build ပထမဆုံးအကြိမ် run တဲ့အခါ package version-related error အသေးအမွေး (dependency resolution) ပေါ်လာနိုင်ခြေ ရှိပါတယ်။ ဖြစ်ရင် error message ကို ပြန်ပေးပါ၊ ချက်ချင်းပြင်ပေးနိုင်ပါတယ်။

## Tech stack & assumptions

| | |
|---|---|
| Backend | **Firebase** (Firestore + Authentication) |
| Auth | Staff email/password login (admin creates accounts in Firebase Console) |
| Language | မြန်မာဘာသာ (UI text) |
| Web hosting | Vercel |
| Android build & distribution | GitHub Actions → GitHub Releases → APK download link in the web app |

Firebase အစား backend တခြားရွေးချင်ရင် (Supabase, custom API) ပြောပေးပါ — `lib/services/` ထဲက service layer နှစ်ခုပဲ (`donor_service.dart`, `auth_service.dart`) ပြောင်းရမှာဖြစ်လို့ UI code တွေကို ထိခိုက်မှာမဟုတ်ပါ။

---

## Setup — အဆင့်ဆင့်

### 1. Flutter SDK ထည့်ရန် (your own computer)

https://docs.flutter.dev/get-started/install ကနေ Flutter install လုပ်ပါ (Chrome browser + Android setup အတွက် Android Studio လည်း လိုအပ်ပါလိမ့်မယ်)။

```
flutter doctor
```
run ပြီး error မရှိအောင် စစ်ဆေးပါ။

### 2. Project ကို bootstrap လုပ်ရန်

Repo ကို clone/download လုပ်ပြီးနောက်:

```
cd blood_bank_app
bash scripts/bootstrap.sh
```

ဒီ script က `android/` နဲ့ `web/` folder တွေကို (git ထဲ မထည့်ထားလို့) auto-generate လုပ်ပေးမှာပါ — Flutter SDK version အသီးသီးနဲ့ တိုက်ဆိုင်အောင်။

### 3. Firebase project ဆောက်ရန်

1. https://console.firebase.google.com → **Add project**
2. **Build → Firestore Database → Create database** (production mode) ဖွင့်ပါ
3. **Build → Authentication → Sign-in method → Email/Password** ကို **Enable** လုပ်ပါ
4. **Authentication → Users → Add user** — ဝန်ထမ်းတစ်ဦးစီအတွက် email/password အကောင့် manual ဖန်တီးပေးပါ (public sign-up မဟုတ်ပါ)
5. Firestore Security Rules — ဒီ repo ထဲက `firestore.rules` ကို Firebase Console → Firestore → Rules မှာ copy/paste လုပ်ပြီး **Publish** နှိပ်ပါ (login ဝင်ထားသူသာ ဒေတာဖတ်/ရေးနိုင်အောင် ကန့်သတ်ထားတာပါ)

### 4. App ကို Firebase project နဲ့ ချိတ်ရန်

```
dart pub global activate flutterfire_cli
flutterfire configure
```

Wizard ကနေ project ရွေး၊ platform (android, web) ရွေးလိုက်ရင် `lib/firebase_options.dart` ကို သင့် project ရဲ့ တကယ့် config values တွေနဲ့ auto-overwrite လုပ်ပေးပါလိမ့်မယ် (ယခု repo ထဲမှာ placeholder value တွေနဲ့ ရှိနေပါတယ်)။

> Firebase ရဲ့ web/Android client config (apiKey စသည်) တွေဟာ secret မဟုတ်ပါ (Google ကိုယ်တိုင် documentation ထဲမှာ ဖော်ပြထားတာပါ) — data security ကတော့ အထက်က firestore.rules အပေါ် မူတည်ပါတယ်။ ဒါကြောင့် `firebase_options.dart` ကို git commit လုပ်ပါ (GitHub Actions/Vercel build တွေအတွက် လိုအပ်ပါတယ်)။

### 5. Local run

```
flutter run -d chrome      # web
flutter run                 # connected Android device/emulator
```

---

## GitHub + Deploy

### 6. GitHub repo ဖန်တီး၍ push

```
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/<your-username>/<your-repo>.git
git push -u origin main
```

### 7. Vercel (Web deploy)

1. https://vercel.com → **Add New → Project** → GitHub repo ကို import လုပ်ပါ
2. Framework preset: **Other** ရွေးထားပါ (repo ထဲက `vercel.json` က build command/output ကို auto handle လုပ်ပေးပါလိမ့်မယ် — Flutter SDK ကို build step ထဲမှာ clone ပြီး web build ထုတ်ပါတယ်)
3. Deploy နှိပ်ရုံပါပဲ — `main` branch ကို push တိုင်း auto-redeploy ဖြစ်ပါလိမ့်မယ်

### 8. Android APK auto-build (GitHub Actions)

`main` branch ကို push တိုင်း `.github/workflows/build.yml` က APK ကို build လုပ်ပြီး **GitHub Release** အနေနဲ့ auto-publish လုပ်ပေးပါလိမ့်မယ် (repo Settings → Actions → General မှာ "Read and write permissions" ဖွင့်ထားဖို့ လိုပါတယ် — default အနေနဲ့ ဖွင့်ထားပါတယ်)။

**အရေးကြီးဆုံးအဆင့်** — `lib/screens/apk_download_screen.dart` ထဲက:

```dart
const String kApkDownloadUrl =
    'https://github.com/YOUR_GITHUB_USERNAME/YOUR_REPO/releases/latest/download/app-release.apk';
```

ကို သင့် GitHub username/repo name အစစ်နဲ့ ပြောင်းပေးပါ (repo push + workflow တစ်ခါ run ပြီးမှ link အလုပ်လုပ်ပါလိမ့်မယ်)။ ဒီ URL pattern (`releases/latest/download/...`) က GitHub ရဲ့ built-in feature ဖြစ်လို့ — release အသစ်တိုင်း automatic အနေနဲ့ latest ကို ညွှန်ပေးနေပါလိမ့်မယ်၊ code ထပ်ပြင်စရာမလိုပါ။

> Note: ဒီ APK ကို Google Play အတွက် proper signing key နဲ့ sign မထားပါ (debug keystore ပါ) — direct download/install (sideload) အတွက်တော့ အဆင်ပြေပါတယ်။ Play Store တင်ချင်ရင် သီးခြား signing setup လိုအပ်ပါတယ် — ပြောပေးပါ၊ ကူညီပါ့မယ်။

---

## Data model (Firestore)

```
donors/{docId}
  memberId: "001"
  name, bloodType, address, phone, viber
  donationHistory: [Timestamp, ...]
  lastDonationDate: Timestamp | null
  createdAt: Timestamp

meta/donorCounter
  lastMemberId: <int>   # transaction-safe auto-increment for memberId
```

"သွေးလှူနိုင်သောစာရင်း" / eligibility စစ်တာကို client-side မှာ (`Donor.isEligible` — `lib/models/donor.dart`) calculate လုပ်ပါတယ် — ၁၂၀ ရက် rule ကို တစ်နေရာတည်းမှာ ပြင်လို့ရအောင် ထားထားပါတယ် (`kDonationEligibilityDays`)။

## ပြောင်းချင်တာများ ရှိရင်

- ၁၂၀ ရက် rule ပြောင်းရန်: `lib/models/donor.dart` ထဲက `kDonationEligibilityDays`
- အရောင်/theme ပြောင်းရန်: `lib/theme/app_theme.dart`
- Blood type list ပြောင်းရန်: `lib/models/donor.dart` ထဲက `kBloodTypes`
