
# VPROFILE_PROJECT

<hr>

## This is the official directory for the VProfile Project

<hr>

## Brief 📃
This project provisions a multi-machine environment using Vagrant and VirtualBox.
It sets up multiple CentOS-based VMs (web, app, db, etc.) with pre-installed software like Nginx, RabbitMQ, and Memcached.

<hr>

## Features 🌟
- Automated provisioning using Vagrant
- Multi-machine setup: Web, App, DB servers
- Pre-installed dependencies: RabbitMQ, Memcached, etc.
- Custom Vagrant base boxes for faster deployment

<hr>

## Requirements to Run 📃
- Linux-based operating system
- Bash / Zsh Shell
- VirtualBox
- Vagrant
- Git

<hr>

## Usage 🪧
## Prerequisites
### Install Zenity
Zenity is required to run the graphical interface. Install it using:
### For RedHat Based 💻:
```bash
sudo yum install zenity
```
or
### For Debian Based 💻:
```bash
sudo apt-get install zenity
```

<br>

## To Run the App 🏃🏻
You can run the application by running this command: **`./mainMenu.sh`**

<br>

## Directory Setup 🎚️
The script ensures that a directory named `DATABASES` is created in the main directory if it does not exist. This directory will contain all the databases created and their corresponding tables.

<br>

## License 🪪
This project is licensed under the GPL License.

<br>

## Acknowledgments 🏁
- [Zenity Documentation](https://help.gnome.org/users/zenity/stable/)
- Bash scripting community and resources
- Project Description inspired by Tohamey & Samy

<br>

## Future Enhancements 💭
- Add support for advanced SQL-like queries.
- Add security measures for database access.

---

Thank you for using our DBMS!  
Feel free to reach out if you encounter any issues or have suggestions.
- [Hossam Mahmoud](hossam.uddin1@gmail.com) ✉️
- [Abdelrahman Khaled](Abdelrahmankhalid27@gmail.com) ✉️
- [Zeyad Tarek](ziadtarekmohamed32@gmail.com) ✉️

## Contributors 👨‍💼
### [Hossam Mahmoud](hossam.uddin1@gmail.com)

<hr>

=====================================
=====================================

Bash Shell Script Database Management System (DBMS):

The Project aim to develop DBMS, that will enable users to store and retrieve the data from main storage.

The Project Features:
The Application will be CLI Menu based app, that will provide to user this Menu items:
Main Menu:
- Create Database
- List Databases
- Connect To Databases
- Drop Database

Up on user Connect to Specific Database, there will be new Screen with this Menu:
- Create Table 
- List Tables
- Drop Table
- Insert into Table
- Select From Table
- Delete From Table
- Update Row

Hints:
- The Database will store as Directory on Current Script File
- Don't use Absolute Path in your scripts
- The Tables store in files, which can be CSV or JSON or XML File format
- You can divide the Table info to two tables: Meta-data and Raw Data in separate files or the same file
- When Create Table, The Meta Data of Table will be: Table Name, Number of Columns, Name Of Columns
- There is assumption that First Column is Primary Key, which used for Delete Rows.
- The Select of Rows displayed in screen/terminal in Accepted/Good Format
- Keep track of Data Types (Digits or Strings) of Column and Validated user input based on it

The Bonus:
- Make the App to accept SQL Code Instead of Above Menu Based
- Make GUI of Application 'Plus" the current CLI view
