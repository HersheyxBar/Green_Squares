import os
import subprocess
import tkinter as tk
from tkinter import messagebox, Toplevel
from tkcalendar import Calendar  # Use tkcalendar's Calendar
from tkinter.ttk import Button
from datetime import datetime, timedelta
import random

class GitHubContributionTool:
    def __init__(self, root):
        self.root = root
        self.root.title("GitHub Contribution Filler")

        # GitHub Details Input
        tk.Label(root, text="GitHub Username:").grid(row=0, column=0, padx=5, pady=5)
        self.username_entry = tk.Entry(root)
        self.username_entry.grid(row=0, column=1, padx=5, pady=5)

        tk.Label(root, text="GitHub Email:").grid(row=1, column=0, padx=5, pady=5)
        self.email_entry = tk.Entry(root)
        self.email_entry.grid(row=1, column=1, padx=5, pady=5)

        tk.Label(root, text="GitHub Token:").grid(row=2, column=0, padx=5, pady=5)
        self.token_entry = tk.Entry(root, show="*")
        self.token_entry.grid(row=2, column=1, padx=5, pady=5)

        tk.Label(root, text="Repository Name:").grid(row=3, column=0, padx=5, pady=5)
        self.repo_entry = tk.Entry(root)
        self.repo_entry.grid(row=3, column=1, padx=5, pady=5)

        tk.Label(root, text="Remote Repository URL:").grid(row=4, column=0, padx=5, pady=5)
        self.remote_url_entry = tk.Entry(root)
        self.remote_url_entry.grid(row=4, column=1, padx=5, pady=5)

        # Date Selection
        tk.Label(root, text="Start Date:").grid(row=5, column=0, padx=5, pady=5)
        self.start_date_entry = tk.Entry(root)
        self.start_date_entry.grid(row=5, column=1, padx=5, pady=5)
        self.start_date_button = Button(root, text="📅", command=self.select_start_date)
        self.start_date_button.grid(row=5, column=2, padx=5, pady=5)
        self.start_date = None

        tk.Label(root, text="End Date:").grid(row=6, column=0, padx=5, pady=5)
        self.end_date_entry = tk.Entry(root)
        self.end_date_entry.grid(row=6, column=1, padx=5, pady=5)
        self.end_date_button = Button(root, text="📅", command=self.select_end_date)
        self.end_date_button.grid(row=6, column=2, padx=5, pady=5)
        self.end_date = None

        tk.Label(root, text="Min Commits per Day:").grid(row=7, column=0, padx=5, pady=5)
        self.min_commits_entry = tk.Entry(root)
        self.min_commits_entry.grid(row=7, column=1, padx=5, pady=5)

        tk.Label(root, text="Max Commits per Day:").grid(row=8, column=0, padx=5, pady=5)
        self.max_commits_entry = tk.Entry(root)
        self.max_commits_entry.grid(row=8, column=1, padx=5, pady=5)

        # Buttons
        tk.Button(root, text="Generate Commits", command=self.generate_commits).grid(row=9, column=0, padx=5, pady=10)
        tk.Button(root, text="Delete Repository Data", command=self.delete_commits_in_range).grid(row=9, column=1, padx=5, pady=10)
        tk.Button(root, text="Commit to Specific Date", command=self.open_specific_date_menu).grid(row=10, columnspan=3, pady=10)

    def select_start_date(self):
        self.start_date = self.select_date("Select Start Date")
        self.start_date_entry.delete(0, tk.END)
        self.start_date_entry.insert(0, self.start_date)

    def select_end_date(self):
        self.end_date = self.select_date("Select End Date")
        self.end_date_entry.delete(0, tk.END)
        self.end_date_entry.insert(0, self.end_date)

    def select_date(self, title):
        def save_date():
            selected_date.set(cal.selection_get())
            date_window.destroy()

        date_window = Toplevel(self.root)
        date_window.title(title)
        selected_date = tk.StringVar()
        cal = Calendar(date_window)
        cal.pack(pady=10)
        Button(date_window, text="Save", command=save_date).pack(pady=10)
        self.root.wait_window(date_window)
        return selected_date.get()

    def generate_commits(self):
        username = self.username_entry.get()
        email = self.email_entry.get()
        token = self.token_entry.get()
        repo = self.repo_entry.get()
        remote_url = self.remote_url_entry.get()
        min_commits = self.min_commits_entry.get()
        max_commits = self.max_commits_entry.get()

        if not (username and email and token and repo and remote_url and self.start_date and self.end_date and min_commits and max_commits):
            messagebox.showerror("Input Error", "All fields are required!")
            return

        try:
            min_commits = int(min_commits)
            max_commits = int(max_commits)
            if not (1 <= min_commits <= max_commits):
                raise ValueError
        except ValueError:
            messagebox.showerror("Input Error", "Invalid commit range.")
            return

        try:
            # Initialize Git repository
            subprocess.run(["git", "init"], check=True)
            subprocess.run(["git", "config", "user.name", username], check=True)
            subprocess.run(["git", "config", "user.email", email], check=True)

            # Create .gitignore and commit tracker file
            with open(".gitignore", "w") as gitignore:
                gitignore.write("*.sh\n")  # Exclude commit-tracker.txt from .gitignore

            with open("commit-tracker.txt", "w") as tracker:
                tracker.write("Commit history tracking file\n")

            # Check if files exist
            if not os.path.exists(".gitignore") or not os.path.exists("commit-tracker.txt"):
                raise FileNotFoundError("Required files .gitignore or commit-tracker.txt are missing.")

            print("Files created successfully:")
            print(".gitignore:", open(".gitignore").read())
            print("commit-tracker.txt:", open("commit-tracker.txt").read())

            # Add all files including untracked ones
            subprocess.run(["git", "add", "."], check=True)

            # Check if there are changes to commit
            status_output = subprocess.run(["git", "status", "--porcelain"], capture_output=True, text=True).stdout
            if status_output.strip():  # Proceed only if there are changes
                subprocess.run(["git", "commit", "-m", "Initial commit"], check=True)
            else:
                print("Nothing to commit. Working tree clean.")

            # Rename branch to 'main'
            subprocess.run(["git", "branch", "-M", "main"], check=True)

            # Configure remote repository
            try:
                subprocess.run(["git", "remote", "add", "origin", remote_url], check=True)
            except subprocess.CalledProcessError:
                subprocess.run(["git", "remote", "set-url", "origin", remote_url], check=True)

            # Set up credential helper
            subprocess.run(["git", "config", "credential.helper", "store"], check=True)
            credentials_path = os.path.expanduser("~/.git-credentials")
            with open(credentials_path, "w") as credentials_file:
                credentials_file.write(f"https://{username}:{token}@{remote_url.split('https://')[1]}\n")

            # Generate commits in chunks
            current_date = datetime.strptime(self.start_date, "%Y-%m-%d")
            end_date = datetime.strptime(self.end_date, "%Y-%m-%d")
            total_commits = 0
            max_commits_per_push = 332

            while current_date <= end_date:
                daily_commits = random.randint(min_commits, max_commits)
                for _ in range(daily_commits):
                    commit_time = current_date + timedelta(
                        hours=random.randint(0, 23), minutes=random.randint(0, 59), seconds=random.randint(0, 59)
                    )
                    with open("commit-tracker.txt", "a") as tracker:
                        tracker.write(f"Commit on {commit_time.strftime('%Y-%m-%d %H:%M:%S')}\n")

                    subprocess.run(["git", "add", "commit-tracker.txt"], check=True)
                    subprocess.run(
                        [
                            "git", "commit", "--date",
                            commit_time.strftime("%Y-%m-%dT%H:%M:%S"),
                            "-m",
                            f"Commit on {commit_time.strftime('%Y-%m-%d %H:%M:%S')}"
                        ],
                        check=True,
                    )
                    total_commits += 1

                    if total_commits >= max_commits_per_push:
                        try:
                            subprocess.run(["git", "push", "origin", "main"], check=True)
                        except subprocess.CalledProcessError as push_error:
                            messagebox.showerror("Push Error", "Failed to push commits. Check your token and repository permissions.")
                            raise push_error
                        total_commits = 0

                current_date += timedelta(days=1)

            if total_commits > 0:
                try:
                    subprocess.run(["git", "push", "origin", "main"], check=True)
                except subprocess.CalledProcessError as push_error:
                    messagebox.showerror("Push Error", "Failed to push commits. Check your token and repository permissions.")
                    raise push_error

            messagebox.showinfo("Success", "Commits have been generated.")
        except subprocess.CalledProcessError as e:
            messagebox.showerror("Error", f"Failed to generate commits: {e}")
        except FileNotFoundError as e:
            messagebox.showerror("Error", str(e))

    def open_specific_date_menu(self):
        def save_specific_date():
            specific_date.set(cal.selection_get())
            num_commits.set(commits_entry.get())
            specific_window.destroy()
            self.commit_to_specific_date(specific_date.get(), num_commits.get())

        specific_window = Toplevel(self.root)
        specific_window.title("Commit to Specific Date")
        specific_date = tk.StringVar()
        num_commits = tk.StringVar()
        cal = Calendar(specific_window)
        cal.pack(pady=10)

        tk.Label(specific_window, text="Number of Commits:").pack()
        commits_entry = tk.Entry(specific_window)
        commits_entry.pack()

        Button(specific_window, text="Save", command=save_specific_date).pack(pady=10)
        self.root.wait_window(specific_window)

    def commit_to_specific_date(self, date, num_commits):
        try:
            num_commits = int(num_commits)
            for _ in range(num_commits):
                commit_time = datetime.strptime(date, "%Y-%m-%d") + timedelta(
                    hours=random.randint(0, 23), minutes=random.randint(0, 59), seconds=random.randint(0, 59)
                )
                with open("commit-tracker.txt", "a") as tracker:
                    tracker.write(f"Commit on {commit_time.strftime('%Y-%m-%d %H:%M:%S')}\n")

                subprocess.run(["git", "add", "commit-tracker.txt"], check=True)
                subprocess.run(
                    [
                        "git", "commit", "--date",
                        commit_time.strftime("%Y-%m-%dT%H:%M:%S"),
                        "-m",
                        f"Commit on {commit_time.strftime('%Y-%m-%d %H:%M:%S')}"
                    ],
                    check=True,
                )

            try:
                subprocess.run(["git", "push", "origin", "main"], check=True)
            except subprocess.CalledProcessError as push_error:
                messagebox.showerror("Push Error", "Failed to push commits. Check your token and repository permissions.")
                raise push_error

            messagebox.showinfo("Success", f"Commits have been added to {date}.")
        except subprocess.CalledProcessError as e:
            messagebox.showerror("Error", f"Failed to commit to specific date: {e}")
        except ValueError:
            messagebox.showerror("Input Error", "Invalid number of commits.")

    def delete_commits_in_range(self):
        confirmation = messagebox.askyesno("Confirm Deletion", "Are you sure you want to delete all commits within the specified range?")
        if not confirmation:
            return

        if not (self.start_date and self.end_date):
            messagebox.showerror("Input Error", "Start and End dates are required!")
            return

        try:
            start_date = datetime.strptime(self.start_date, "%Y-%m-%d")
            end_date = datetime.strptime(self.end_date, "%Y-%m-%d")

            # Revert commits in the specified range
            while start_date <= end_date:
                commit_time = start_date + timedelta(
                    hours=random.randint(0, 23), minutes=random.randint(0, 59), seconds=random.randint(0, 59)
                )
                with open("commit-tracker.txt", "a") as tracker:
                    tracker.write(f"Reverting commit on {commit_time.strftime('%Y-%m-%d %H:%M:%S')}\n")

                subprocess.run(["git", "add", "commit-tracker.txt"], check=True)
                subprocess.run(
                    [
                        "git", "commit", "--date",
                        commit_time.strftime("%Y-%m-%dT%H:%M:%S"),
                        "-m",
                        f"Reverting commit on {commit_time.strftime('%Y-%m-%d %H:%M:%S')}"
                    ],
                    check=True,
                )
                start_date += timedelta(days=1)

            # Push changes to remote
            try:
                subprocess.run(["git", "push", "origin", "main"], check=True)
            except subprocess.CalledProcessError as push_error:
                messagebox.showerror("Push Error", "Failed to push revert changes. Check your token and repository permissions.")
                raise push_error

            messagebox.showinfo("Success", "Commits within the specified range have been deleted.")
        except subprocess.CalledProcessError as e:
            messagebox.showerror("Error", f"Failed to delete commits: {e}")
        except ValueError as ve:
            messagebox.showerror("Input Error", str(ve))

if __name__ == "__main__":
    root = tk.Tk()
    app = GitHubContributionTool(root)
    root.mainloop()
