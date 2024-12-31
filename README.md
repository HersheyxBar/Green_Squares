# Green_Squares
Python-based GUI tool that helps you manage your GitHub contributions by allowing you to generate commits with custom dates, times, and patterns

# GitHub Contribution Generator

A  GUI tool for managing and generating GitHub contribution patterns. This tool allows users to create, manage, and customize their GitHub commit history through a user-friendly interface.

## 🌟 Features

- **Intuitive GUI Interface**: Easy-to-use graphical interface built with tkinter
- **Date Range Selection**: Visual calendar picker for selecting commit date ranges
- **Flexible Commit Patterns**: 
  - Set minimum and maximum commits per day
  - Random distribution of commits throughout the day
  - Custom commit messages and timestamps
- **GitHub Integration**:
  - Direct GitHub repository management
  - Secure token-based authentication
  - Remote repository configuration
- **Advanced Controls**:
  - Commit to specific dates
  - Delete commits within a date range
  - Manage repository data

## 🔧 Requirements

- Python 3.6+
- tkinter
- tkcalendar
- Git (installed and configured)

## 📦 Installation

1. Clone the repository:
```bash
git clone [https://github.com/HersheyxBar/Green_Squares.git]
cd Green_Squares
```

2. Install required dependencies:
```bash
pip install tkcalendar
```

## 🚀 Usage

1. Launch the application:
```bash
python3 commitgui.sh
```

2. Enter your GitHub credentials:
   - Username
   - Email
   - Personal Access Token (with repo permissions)
   - Repository name
   - Remote repository URL

3. Select date range and commit preferences:
   - Choose start and end dates using the calendar
   - Set minimum and maximum commits per day
   - Configure any additional options

4. Click "Generate Commits" to create your contribution pattern

## 🔐 Security Features

- Secure token-based authentication
- Local credential storage
- Safe repository management
- Protected configuration files

## 🛠️ Advanced Features

### Specific Date Commits
- Target individual dates for commit generation
- Customize commit count for specific dates
- Random time distribution within the selected date

### Commit Management
- Delete commits within a specified date range
- Revert changes when needed
- Clean repository management
