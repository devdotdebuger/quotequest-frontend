# QuoteQuest

A web application for sharing and discovering inspiring quotes.

## Setup Instructions

### 1. Supabase Setup

1. Create a Supabase account at [https://supabase.com](https://supabase.com)
2. Create a new project
3. Go to the SQL Editor in your Supabase dashboard
4. Copy and paste the contents of `setup.sql` into the editor and run it
5. This will create the necessary tables and set up Row Level Security (RLS) policies

### 2. Update Supabase Credentials

In each HTML file (`index.html`, `login.html`, `register.html`, `profile.html`), update the Supabase URL and anon key with your project's credentials:

```javascript
const SUPABASE_URL = 'YOUR_SUPABASE_URL';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';
```

You can find these values in your Supabase project settings under "API".

### 3. Serve the Files

You can serve the files using any local server. For example, with Python:

```bash
# Python 3
python -m http.server

# Python 2
python -m SimpleHTTPServer
```

Or with Node.js:

```bash
npx serve
```

Then open your browser and navigate to `http://localhost:8000` (or whatever port your server is using).

## Troubleshooting

### Quotes Not Loading

If quotes are not loading, check the following:

1. **Database Tables**: Make sure the `quotes` and `likes` tables exist in your Supabase database. Run the SQL in `setup.sql` if you haven't already.

2. **Authentication**: Ensure you're properly logged in. The application requires authentication to view quotes.

3. **Console Errors**: Open your browser's developer tools (F12) and check the console for any error messages.

4. **RLS Policies**: Verify that the Row Level Security policies are correctly set up in Supabase. The quotes table should have a policy that allows all authenticated users to view quotes.

5. **Network Issues**: Check if there are any network errors in the browser's developer tools.

### Adding Quotes

If you're having trouble adding quotes:

1. Make sure you're logged in
2. Check the console for any error messages
3. Verify that the `quotes` table has the correct structure with columns for `text`, `author`, `category`, and `user_id`
4. Ensure the RLS policy for inserting quotes is correctly set up

### Profile Issues

If your profile is not loading or updating:

1. Check if the `profiles` table exists and has the correct structure
2. Verify that the RLS policies for profiles are correctly set up
3. Make sure your user ID is correctly associated with your profile

## Database Structure

The application uses the following tables:

- **profiles**: Stores user profile information
- **quotes**: Stores quotes with text, author, category, and user_id
- **likes**: Stores which users have liked which quotes

## Features

- User authentication (register, login, logout)
- Create, view, like, and unlike quotes
- User profiles with bio and stats
- Dark/light theme toggle
- Responsive design for mobile and desktop 