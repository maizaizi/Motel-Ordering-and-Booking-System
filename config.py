import connect
import mysql.connector
import os
from datetime import datetime, date
#accept image type when uploading  images
# ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}
#the folder for the uploaded images, this is for the local app
UPLOAD_FOLDER = 'static/images/'


dbconn = None
connection = None
# connect with database, and get the cursor function
def get_cursor():
    global dbconn
    global connection
    connection = mysql.connector.connect(user=connect.dbuser, \
    password=connect.dbpass, host=connect.dbhost,\
    database=connect.dbname, autocommit=True)
    dbconn = connection.cursor(dictionary=True)
    return connection, dbconn  # return both connection and cursor

# def allowed_file(filename):
#     return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# def is_image_exist(image_name):
#     # Construct the full path to the image file
#     image_path = os.path.join(UPLOAD_FOLDER, image_name)
#     # Check if the file exists
#     if os.path.exists(image_path):
#         return True
#     else:
#         return False


# Define allowed file types for image upload
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}
MAX_FILENAME_LENGTH = 500
def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS and \
           len(filename) <= MAX_FILENAME_LENGTH

#define format date
def format_date(value, format='%d/%m/%Y'):
    """Format a date string or datetime.date object to 'DD/MM/YYYY'."""
    if isinstance(value, date):  
        return value.strftime(format)
    elif isinstance(value, str):
        try:
            date_obj = datetime.strptime(value, '%Y-%m-%d')
            return date_obj.strftime(format)
        except ValueError:
            return value 
    else:
        return value

def format_time(value, format='%d/%m/%Y %I:%M %p'):
    """Format a date string or datetime.date object to 'DD/MM/YYYY HH:MM AM/PM'."""
    if isinstance(value, datetime) or isinstance(value, date):  
        return value.strftime(format)
    elif isinstance(value, str):
        try:
            date_obj = datetime.strptime(value, '%Y-%m-%d %H:%M:%S')
            return date_obj.strftime(format)
        except ValueError:
            return value 
    else:
        return value
def get_staff_info_by_id(staff_id):
    connection, cursor = get_cursor()
    cursor.execute("""
        SELECT *
        FROM staff 
        WHERE staff_id = %s
    """, (staff_id,))
    staff_info = cursor.fetchone()
    cursor.close()
    connection.close()
    return staff_info

def get_customer_info_by_id(customer_id):
    connection, cursor = get_cursor()
    cursor.execute("""
        SELECT *
        FROM customer 
        WHERE customer_id = %s
    """, (customer_id,))
    customer_info = cursor.fetchone()
    cursor.close()
    connection.close()
    return customer_info

def get_manager_info_by_id(manager_id):
    connection, cursor = get_cursor()
    cursor.execute("""
        SELECT *
        FROM manager
        WHERE manager_id = %s
    """, (manager_id,))
    manager_info = cursor.fetchone()
    cursor.close()
    connection.close()
    return manager_info 

