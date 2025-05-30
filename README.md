# SiSDevTemplate

This project includes:
1. A sample streamlit app where it first tries a connection via the SiS method then falls back to a local laptop connection to your Snowflake account.  So, the connection logic here helps you do dev locally before moving onto test in SiS
2. An example requirements file where you fill it in by answering a bunch of questions.  Then delete the top part and run the command provided there to convert it into rules.  From that point on, only use rules rather than this requirements file.  Hint, you can ask use internal information with [Gemini Pro](https://gemini.google.com/) to design your high level and detailed design. 
3. Some code which supposedly enables you to tell Cursor when and what to push to Git.  I'm still running into sync problems...
