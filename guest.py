from flask import Flask, render_template, Blueprint, flash, jsonify
from auth import auth_blueprint
from config import get_cursor
from flask_wtf import FlaskForm
from datetime import datetime,date,timedelta
from wtforms import StringField, TextAreaField, SubmitField
from wtforms.validators import DataRequired, Email
from flask_mail import Mail, Message

app = Flask(__name__)

guest_blueprint = Blueprint('guest', __name__)
app.config["MAIL_SERVER"] = "smtp.gmail.com"
app.config["MAIL_PORT"] = 465
app.config["MAIL_USERNAME"] = 'bright.tech.ap@gmail.com'  
app.config["MAIL_PASSWORD"] = 'xupijwvjmgygqljg'
app.config["MAIL_USE_TLS"] = False
app.config["MAIL_USE_SSL"] = True

mail = Mail(app)


@guest_blueprint.route('/')
def home():
    rooms_info = rooms()
    return render_template('home/guest.html', rooms=rooms_info)




def get_manager():
    connection, cursor = get_cursor()
    cursor.execute("""
        SELECT manager.first_name, manager.last_name, manager.profile_image, manager.position
        FROM manager
        JOIN account ON manager.account_id = account.account_id
        WHERE manager.status = 'active'
    """)
    manager_info = cursor.fetchall()
    cursor.close()
    connection.close()
    return manager_info


def get_all_staff():
    connection, cursor = get_cursor()
    cursor.execute("""
        SELECT staff.first_name, staff.last_name, staff.profile_image, staff.position
        FROM staff
        JOIN account ON staff.account_id = account.account_id
        WHERE staff.status = 'active'
    """)
    staff_info = cursor.fetchall()
    cursor.close()
    connection.close()
    return staff_info


@guest_blueprint.route('/about_us')
def about_us():
    manager_info = get_manager()
    staff_info = get_all_staff()
    return render_template('home/about_us.html', manager=manager_info, staff=staff_info)


class ContactForm(FlaskForm):
    name = StringField("Name", validators=[DataRequired(message="Please enter your name.")])
    email = StringField("Email", validators=[DataRequired(message="Please enter your email address"), Email()])
    message = TextAreaField("Message", validators=[DataRequired(message="Please enter a message.")])
    submit = SubmitField("Send")

@guest_blueprint.route('/contact', methods=['GET', 'POST'])
def contact():
    form = ContactForm()
    manager_info = get_manager()
    staff_info = get_all_staff()
    flash('Your message has been sent successfully!', 'success')
    return render_template('home/about_us.html', manager=manager_info, staff=staff_info, form=form)

@guest_blueprint.route('/get-coffee-and-hot-drinks')
def get_coffee_and_hot_drinks():
    connection, cursor = get_cursor() 
    try:
        cursor.execute("SELECT name, description, unit_price, image FROM product WHERE category_id IN (1, 2) AND is_available = TRUE")
        products = cursor.fetchall()
        product_list = []
        for product in products:
            product_dict = {
                'name': product['name'],       
                'description': product['description'],
                'price': product['unit_price'],
                'image': f"{product['image']}"
            }
            product_list.append(product_dict)
    except Exception as e:
        cursor.close()  
        print(f"Error: {e}")
        return jsonify({"error": "Failed to fetch products"}), 500
    finally:
        cursor.close()
        connection.close() 

    return jsonify(product_list)

@guest_blueprint.route('/get_cold_drinks')
def get_cold_drinks():
    connection, cursor = get_cursor() 
    try:
        cursor.execute("SELECT name, description, unit_price, image FROM product WHERE category_id IN (3, 5) AND is_available = TRUE")
        products = cursor.fetchall()
        product_list = []
        for product in products:
            product_dict = {
                'name': product['name'],       
                'description': product['description'],
                'price': product['unit_price'],
                'image': f"{product['image']}"
            }
            product_list.append(product_dict)
    except Exception as e:
        cursor.close()  
        print(f"Error: {e}")
        return jsonify({"error": "Failed to fetch products"}), 500
    finally:
        cursor.close()
        connection.close() 

    return jsonify(product_list)

@guest_blueprint.route('/get_milkshake')
def get_milkshake():
    connection, cursor = get_cursor() 
    try:
        cursor.execute("SELECT name, description, unit_price, image FROM product WHERE category_id = 4 AND is_available = TRUE")
        products = cursor.fetchall()
        product_list = []
        for product in products:
            product_dict = {
                'name': product['name'],       
                'description': product['description'],
                'price': product['unit_price'],
                'image': f"{product['image']}"
            }
            product_list.append(product_dict)
    except Exception as e:
        cursor.close()  
        print(f"Error: {e}")
        return jsonify({"error": "Failed to fetch products"}), 500
    finally:
        cursor.close()
        connection.close() 

    return jsonify(product_list)

@guest_blueprint.route('/quicktaste')
def quicktaste():
    connection, cursor = get_cursor() 
    try:
        cursor.execute("SELECT name, description, unit_price, image FROM product WHERE category_id = 6 AND is_available = TRUE")
        products = cursor.fetchall()
        product_list = []
        for product in products:
            product_dict = {
                'name': product['name'],       
                'description': product['description'],
                'price': product['unit_price'],
                'image': f"{product['image']}"
            }
            product_list.append(product_dict)
    except Exception as e:
        cursor.close()  
        print(f"Error: {e}")
        return jsonify({"error": "Failed to fetch products"}), 500
    finally:
        cursor.close()
        connection.close() 

    return jsonify(product_list)

@guest_blueprint.route('/chill')
def chill():
    connection, cursor = get_cursor() 
    try:
        cursor.execute("SELECT name, description, unit_price, image FROM product WHERE category_id = 7 AND is_available = TRUE")
        products = cursor.fetchall()
        product_list = []
        for product in products:
            product_dict = {
                'name': product['name'],       
                'description': product['description'],
                'price': product['unit_price'],
                'image': f"{product['image']}"
            }
            product_list.append(product_dict)
    except Exception as e:
        cursor.close()  
        print(f"Error: {e}")
        return jsonify({"error": "Failed to fetch products"}), 500
    finally:
        cursor.close()
        connection.close() 

    return jsonify(product_list)

@guest_blueprint.route('/essentials')
def essentials():
    connection, cursor = get_cursor() 
    try:
        cursor.execute("SELECT name, description, unit_price, image FROM product WHERE category_id = 8 AND is_available = TRUE")
        products = cursor.fetchall()
        product_list = []
        for product in products:
            product_dict = {
                'name': product['name'],       
                'description': product['description'],
                'price': product['unit_price'],
                'image': f"{product['image']}"
            }
            product_list.append(product_dict)
    except Exception as e:
        cursor.close()  
        print(f"Error: {e}")
        return jsonify({"error": "Failed to fetch products"}), 500
    finally:
        cursor.close()
        connection.close() 

    return jsonify(product_list)


def rooms():
    connection, cursor = get_cursor()
    cursor.execute("SELECT * FROM accommodation WHERE is_available = TRUE AND room_status = 'Open'")
    rooms_info = cursor.fetchall()
    cursor.close()
    connection.close()
    return rooms_info