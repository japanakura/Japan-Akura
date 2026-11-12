# Japan Akura 2.0 — GitHub Pages + Supabase starter

A multi-page Japanese-learning website for Sri Lankan students, built with HTML5, CSS3 and vanilla JavaScript.

## Included pages
- `index.html` — homepage
- `beginner.html` — beginner academy
- `alphabet.html` — Hiragana/Katakana
- `kanji.html` — Kanji academy
- `vocabulary.html` — flashcards and vocabulary
- `grammar.html`, `listening.html`, `reading.html`
- `jlpt.html`, `jft.html`, `nat.html`, `exams.html`, `take-exam.html`
- `lesson.html` — individual lesson view
- `dashboard.html` — local demo progress and exam results
- `culture.html`, `about.html`, `contact.html`
- `admin.html` — admin control centre

## 1. Preview locally
1. Extract the ZIP.
2. Open `index.html` in a modern browser.
3. Navigate through the pages and try the sample quizzes.
4. The demo student progress is stored in that browser's LocalStorage.

Some browsers restrict scripts when opening files directly. If so, run a local static server:
- VS Code: install the Live Server extension and choose **Open with Live Server**.
- Or use Python: `python -m http.server 8000` in the project folder, then visit `http://localhost:8000`.

## 2. Publish on GitHub Pages
1. Create a GitHub repository, e.g. `japan-akura`.
2. Upload all project files and folders to the repository root. Keep `index.html` in the root.
3. In GitHub, open **Settings → Pages**.
4. Under **Build and deployment**, choose **Deploy from a branch**.
5. Select branch `main` and folder `/ (root)`, then Save.
6. Wait for the Pages deployment and open the URL shown in Settings → Pages.

This is a static website. GitHub Pages does not run a private server or database.

## 3. Enable real online admin publishing with Supabase
The admin panel is a Supabase-ready starter. Without Supabase settings it shows demo mode. To publish edits to every visitor, configure Supabase:

1. Create a project at https://supabase.com/.
2. Open **SQL Editor**, paste the contents of `supabase/schema.sql`, and run it.
3. In **Authentication → Users**, create your own admin account.
4. Copy that user's UUID. In SQL Editor run:
   ```sql
   insert into public.profiles (id, display_name, role)
   values ('YOUR-AUTH-USER-UUID', 'Japan Akura Admin', 'admin')
   on conflict (id) do update set role = 'admin';
   ```
5. Open **Project Settings → API** and copy the Project URL and anon/publishable key.
6. Paste them into `assets/js/config.js`:
   ```js
   window.JA_CONFIG = {
     supabaseUrl: "https://YOUR-PROJECT.supabase.co",
     supabaseAnonKey: "YOUR-ANON-OR-PUBLISHABLE-KEY"
   };
   ```
7. Commit and push the updated file to GitHub. GitHub Pages will redeploy.
8. Open `/admin.html` on your published site and sign in with your admin account.

### Security notes
- Frontend code may contain only the Supabase anon/publishable key. Never add the `service_role` key, database password, or private secrets to this repository.
- The included SQL enables Row Level Security and restricts lesson changes to users whose profile role is `admin`.
- Keep admin sign-up controlled. Do not publicly expose an admin registration link.
- Review the RLS policies and test with a separate student account before launch.
- The current admin interface supports lesson create/edit/delete and exam-paper create/edit/delete, including question JSON and publish/draft status. File upload UI, student account management and full remote student dashboards are not included yet; schema tables and storage policies are provided as a starting point for those extensions.
- Supabase email/password authentication and database require your own Supabase project and configuration.

## 4. Content and media
- The included lessons and questions are original starter examples for demonstration.
- They are not official JLPT, JFT-Basic or NAT-TEST papers.
- External Google Fonts, jsDelivr Supabase library and Unsplash images require an internet connection.
- Replace sample questions with carefully checked, licensed learning content before public launch.

## 5. Important project limitations
- The static demo saves student progress and quiz results in the current browser only.
- To synchronize student progress across devices, implement authenticated Supabase reads/writes for `student_progress` and `exam_results`.
- GitHub Pages hosts the frontend only; Supabase provides authentication, database and storage.
- This is a production-oriented starter, not a fully audited production LMS. Before accepting real student data, test security policies, accessibility, content accuracy, backups and privacy notices.

## 6. Technology
HTML5 · CSS3 · Vanilla JavaScript · Supabase JS v2 · GitHub Pages
