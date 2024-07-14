from flask import Blueprint, render_template, redirect, url_for,\
    session, request, flash, jsonify
from config import get_cursor, allowed_file, MAX_FILENAME_LENGTH
import re
import os
from datetime import date, timedelta, datetime
from auth import role_required
from werkzeug.utils import secure_filename
from config import get_cursor, get_customer_info_by_id, get_staff_info_by_id
from extensions import socketio, hashing
from flask_socketio import join_room, leave_room, send  

staff_blueprint = Blueprint('staff', __name__)
staff_rooms = {}

# Get staff information + account information
def get_staff_info(email):
    connection, cursor = get_cursor()
    cursor.execute("""
        SELECT staff.*
        FROM account 
        JOIN staff ON account.account_id = staff.account_id
        WHERE account.email = %s
    """, (email,))
    staff_info = cursor.fetchone()
    cursor.close()
    connection.close()
    return staff_info

def get_unread_messages_for_staff(staff_id):
    connection, cursor = get_cursor()
    cursor.execute("""
        SELECT message.*, customer.first_name, customer.last_name
        FROM message
        JOIN customer ON message.customer_id = customer.customer_id
        WHERE (staff_id = %s OR staff_id IS NULL)AND is_read = FALSE AND sender_type = 'customer'
    """, (staff_id,))
    unread_messages = cursor.fetchall()
    cursor.close()
    connection.close()
    return unread_messages

@staff_blueprint.route('/mark_message_as_read/<int:message_id>', methods=['POST'])
@role_required(['staff'])
def mark_message_as_read_staff(message_id):
    connection, cursor = get_cursor()
    cursor.execute("""
        UPDATE message
        SET is_read = TRUE
        WHERE message_id = %s
    """, (message_id,))
    connection.commit()
    cursor.close()
    connection.close()
    return '', 204  # Return a no content response

@staff_blueprint.route('/')
@role_required(['staff'])
def staff():
    email = session.get('email')
    staff_info = get_staff_info(email)
    unread_messages = get_unread_messages_for_staff(staff_info['staff_id'])
    return render_template('staff/staff_dashboard.html', staff_info=staff_info, unread_messages=unread_messages)

# Define a name for upload image profile
def upload_image_profile(staff_id, file):
    filename = secure_filename(file.filename)
    unique_filename = f"user_{staff_id}_{filename}"

    base_dir = os.path.dirname(os.path.abspath(__file__))
    upload_folder = os.path.join(base_dir, 'static/staff/')
    file_path = os.path.join(upload_folder, unique_filename)

    # Check if the file path already exists
    if os.path.exists(file_path):
        os.remove(file_path)

    file.save(file_path)
    connection, cursor = get_cursor()
    cursor.execute("UPDATE staff SET profile_image = %s WHERE staff_id = %s", (unique_filename, staff_id))
    connection.commit()


#Handling image update
@staff_blueprint.route('/upload_image_profile', methods=["POST"])
@role_required(['staff'])
def handle_upload_image_profile():
    if 'profile_image' not in request.files:
        flash('No file part')
        return redirect(url_for('staff.staff_updateprofile'))

    file = request.files['profile_image']

    if file.filename == '':
        flash('No selected file')
        return redirect(url_for('staff.staff_updateprofile'))

    if len(file.filename) > MAX_FILENAME_LENGTH:
        flash('File name is too long')
        return redirect(url_for('staff.staff_updateprofile'))

    if file and allowed_file(file.filename):
        account_id = session.get('id')
        connection, cursor = get_cursor()
        cursor.execute("SELECT role FROM account WHERE account_id = %s", (account_id,))
        result = cursor.fetchone()
        if result is not None and result['role'] == 'staff':
            cursor.execute("SELECT staff_id FROM staff WHERE account_id = %s", (account_id,))
            result = cursor.fetchone()
            if result is not None:
                upload_image_profile(result['staff_id'], file)
                flash('Profile image successfully uploaded')
        else:
            flash('You do not have permission to perform this action')
        return redirect(url_for('staff.staff_updateprofile'))
    else:
        flash('Invalid file type')
        return redirect(url_for('staff.staff_updateprofile'))

#staff update profile
@staff_blueprint.route('/staff_updateprofile', methods=["GET", "POST"])
@role_required(['staff'])
def staff_updateprofile():
    email = session.get('email')
    account_id = session.get('id')
    staff_info = get_staff_info(email)
    unread_messages = get_unread_messages_for_staff(staff_info['staff_id'])
    connection, cursor = get_cursor()
    
    # Set the validation for birthday ages from 16-100
    today = date.today()
    max_date = today - timedelta(days=16*365)
    min_date = today - timedelta(days=100*365)
    max_date_str = (date.today() - timedelta(days=16*365)).strftime("%Y-%m-%d")
    min_date_str = (date.today() - timedelta(days=100*365)).strftime("%Y-%m-%d")

    # Initially fetch the staff_id and other details
    cursor.execute(
        'SELECT a.email, s.* FROM account a INNER JOIN staff s ON a.account_id = s.account_id WHERE a.account_id = %s', 
        (account_id,))

    account = cursor.fetchone()
    staff_id = account['staff_id'] if account else None

    if request.method == 'POST':
        email = request.form['email']
        first_name = request.form['first_name']
        last_name = request.form['last_name']
        phone_number = request.form['phone_number']
        date_of_birth = request.form['date_of_birth']
        gender = request.form['gender'].lower()
        position = request.form['position']
        new_password = request.form['new_password']
        confirm_password = request.form['confirm_password']

        

        # Update password check
        if new_password and new_password != confirm_password:
            flash('New passwords do not match.', 'error')
            return render_template('staff/staff_updateprofile.html', account=account, staff_info=staff_info)

        if new_password and (len(new_password) < 8 or not any(char.isupper() for char in new_password) 
            or not any(char.islower() for char in new_password) or not any(char.isdigit() for char in new_password)):
            flash('Password must be at least 8 characters long and contain a mix of uppercase, lowercase, and numeric characters.', 'error')
            return redirect(url_for('staff.staff_updateprofile'))

        # Update the account table for email and password
        if new_password:
            password_hash = hashing.hash_value(new_password, salt='S1#e2!r3@t4$')
            cursor.execute('UPDATE account SET email = %s, password = %s WHERE account_id = %s', 
                           (email, password_hash, account_id))
        else:
            cursor.execute('UPDATE account SET email = %s WHERE account_id = %s', (email, account_id))
        
        # Commit changes to the database
        connection.commit()

        #set the validation for birthday ages from 16-100
        if date_of_birth < min_date_str or date_of_birth > max_date_str:
            flash('Date of birth must be between 16 and 100 years ago.', 'error')
            return render_template('staff/staff_updateprofile.html', account=account, staff_info=staff_info, max_date=max_date_str, min_date=min_date_str)


        # Update the staff table using staff_id 
        cursor.execute("""
            UPDATE staff SET first_name = %s, last_name = %s, phone_number = %s, date_of_birth = %s, 
            gender = %s, position = %s WHERE staff_id = %s
            """, (first_name, last_name, phone_number, date_of_birth, gender, position, staff_id))

        # Commit changes to the database
        connection.commit()

        flash('Profile updated successfully.')
        return redirect(url_for('staff.staff'))

    # Render page with current account information
    return render_template('staff/staff_updateprofile.html', account=account, staff_info=staff_info, 
                           max_date=max_date_str, min_date=min_date_str, unread_messages=unread_messages)


@staff_blueprint.route('/orders', methods=['GET', 'POST'])
@role_required(['staff'])
def manage_orders():
    email = session.get('email')
    staff_info = get_staff_info(email)
    unread_messages = get_unread_messages_for_staff(staff_info['staff_id'])
    filter_status = request.args.get('status', 'active')
    search_email = request.args.get('search_email', '').strip()
    pickup_date = request.args.get('pickup_date', '').strip()
    sort_by = request.args.get('sort_by', 'order_id')  # Default sort by order_id
    sort_order = request.args.get('sort_order', 'asc')  # Default sort order ascending
    
    # Determine the next sort order for toggling
    next_sort_order = 'desc' if sort_order == 'asc' else 'asc'
    
    connection, cursor = get_cursor()

    query = """
        SELECT o.order_id, o.total_price, o.status, o.created_at, o.last_updated, 
               o.scheduled_pickup_time, c.first_name, c.last_name, acc.email
        FROM orders o
        JOIN customer c ON o.customer_id = c.customer_id
        JOIN account acc ON c.account_id = acc.account_id
        WHERE 1=1
    """
    params = []

    if filter_status != 'active':
        query += " AND o.status = %s"
        params.append(filter_status)
    else:
        query += " AND o.status IN ('ordered', 'preparing', 'ready for collection')"

    if search_email:
        query += " AND acc.email LIKE %s"
        params.append(f"%{search_email}%")

    if pickup_date:
        query += " AND DATE(o.scheduled_pickup_time) = %s"
        params.append(pickup_date)

    query += f" ORDER BY o.{sort_by} {sort_order.upper()}"

    cursor.execute(query, params)
    orders = cursor.fetchall()

    if request.method == 'POST':
        order_id = request.form.get('order_id')
        new_status = request.form.get('new_status')
        valid_statuses = ['ordered', 'preparing', 'ready for collection', 'collected', 'cancelled']
        if order_id and new_status in valid_statuses:
            cursor.execute("""
                UPDATE orders 
                SET status = %s, last_updated = NOW()
                WHERE order_id = %s
            """, (new_status, order_id))
            connection.commit()
            flash(f"Order {order_id} status updated to {new_status}.", "success")
        else:
            flash(f"Invalid status value: {new_status}", "danger")
        return redirect(url_for('staff.manage_orders', status=filter_status, search_email=search_email, pickup_date=pickup_date, sort_by=sort_by, sort_order=sort_order))

    cursor.close()
    connection.close()

    return render_template('staff/staff_manage_orders.html', 
                           orders=orders, 
                           staff_info=staff_info, 
                           filter_status=filter_status, 
                           search_email=search_email, 
                           pickup_date=pickup_date, 
                           sort_by=sort_by, 
                           sort_order=sort_order, 
                           next_sort_order=next_sort_order, unread_messages=unread_messages)


# Staff view order details
@staff_blueprint.route('/order_details/<int:order_id>', methods=['GET'])
@role_required(['staff'])
def order_details(order_id):
    email = session.get('email')
    staff_info = get_staff_info(email)
    unread_messages = get_unread_messages_for_staff(staff_info['staff_id'])
    
    connection, cursor = get_cursor()
    
    try:
        cursor.execute("SET NAMES utf8mb4;")
        cursor.execute("SET CHARACTER SET utf8mb4;")
        cursor.execute("SET character_set_connection=utf8mb4;")
        
        cursor.execute("""
            SELECT o.*, c.first_name, c.last_name, p.code AS promo_code
            FROM orders o
            JOIN customer c ON o.customer_id = c.customer_id
            LEFT JOIN promotion p ON o.promotion_id = p.promotion_id
            WHERE o.order_id = %s
        """, (order_id,))
        order = cursor.fetchone()
        
        if not order:
            flash("Order not found.", "error")
            return redirect(url_for('staff.manage_orders'))
        
        cursor.execute("""
            SELECT oi.*, p.name AS product_name, p.unit_price
            FROM order_item oi
            JOIN product p ON oi.product_id = p.product_id
            WHERE oi.order_id = %s
        """, (order_id,))
        order_items = cursor.fetchall()
    except Exception as e:
        flash(f"Failed to retrieve order details. Error: {str(e)}", "danger")
        order = None
        order_items = []
    finally:
        cursor.close()
        connection.close()
    
    # Handle display of 'None' or 'No Promotion' if promo_code is empty
    promo_code_display = order['promo_code'] if order and order['promo_code'] else 'None'
    
    return render_template('staff/staff_order_details.html', order=order, order_items=order_items, staff_info=staff_info,
                           unread_messages=unread_messages, promo_code_display=promo_code_display)

# Staff view order history
@staff_blueprint.route('/history_orders', methods=['GET'])
@role_required(['staff'])
def view_history_orders():
    email = session.get('email')
    staff_info = get_staff_info(email)
    unread_messages = get_unread_messages_for_staff(staff_info['staff_id'])
    
    filter_status = request.args.get('status', '').strip()
    search_email = request.args.get('search_email', '').strip()
    pickup_date = request.args.get('pickup_date', '').strip()
    
    connection, cursor = get_cursor()
    
    query = """
        SELECT o.order_id, o.total_price, o.status, o.created_at, o.last_updated, 
               o.scheduled_pickup_time, c.first_name, c.last_name, acc.email
        FROM orders o
        JOIN customer c ON o.customer_id = c.customer_id
        JOIN account acc ON c.account_id = acc.account_id
        WHERE o.status IN ('collected', 'cancelled')
    """
    params = []

    if filter_status:
        query += " AND o.status = %s"
        params.append(filter_status)

    if search_email:
        query += " AND acc.email LIKE %s"
        params.append(f"%{search_email}%")

    if pickup_date:
        query += " AND DATE(o.scheduled_pickup_time) = %s"
        params.append(pickup_date)

    query += " ORDER BY o.created_at DESC"

    try:
        cursor.execute(query, params)
        history_orders = cursor.fetchall()
    except Exception as e:
        flash(f"Failed to retrieve historical orders. Error: {str(e)}", "danger")
        history_orders = []
    finally:
        cursor.close()
        connection.close()
    
    return render_template('staff/staff_history_orders.html', history_orders=history_orders, 
                           staff_info=staff_info, filter_status=filter_status, search_email=search_email, 
                           pickup_date=pickup_date, unread_messages=unread_messages)

# Staff view order details
@staff_blueprint.route('/history_order_details/<int:order_id>', methods=['GET'])
@role_required(['staff'])
def history_order_details(order_id):
    email = session.get('email')
    staff_info = get_staff_info(email)
    unread_messages = get_unread_messages_for_staff(staff_info['staff_id'])
    
    connection, cursor = get_cursor()
    
    try:
        cursor.execute("SET NAMES utf8mb4;")
        cursor.execute("SET CHARACTER SET utf8mb4;")
        cursor.execute("SET character_set_connection=utf8mb4;")
        
        cursor.execute("""
            SELECT o.*, c.first_name, c.last_name
            FROM orders o
            JOIN customer c ON o.customer_id = c.customer_id
            WHERE o.order_id = %s
        """, (order_id,))
        order = cursor.fetchone()
        
        if not order:
            flash("Order not found.", "error")
            return redirect(url_for('staff.view_history_orders'))
        
        cursor.execute("""
            SELECT oi.*, p.name AS product_name, p.unit_price
            FROM order_item oi
            JOIN product p ON oi.product_id = p.product_id
            WHERE oi.order_id = %s
        """, (order_id,))
        order_items = cursor.fetchall()
    except Exception as e:
        flash(f"Failed to retrieve order details. Error: {str(e)}", "danger")
        order = None
        order_items = []
    finally:
        cursor.close()
        connection.close()
    
    return render_template('staff/staff_history_order_details.html', order=order, order_items=order_items, 
                           staff_info=staff_info, unread_messages=unread_messages)

# Staff view inventory
@staff_blueprint.route('/monitor_inventory')
@role_required(['staff'])
def monitor_inventory():
    email = session.get('email')
    staff_info = get_staff_info(email)
    unread_messages = get_unread_messages_for_staff(staff_info['staff_id'])
    page = request.args.get('page', 1, type=int)
    items_per_page = 10
    offset = (page - 1) * items_per_page
    category_filter = request.args.get('category', '')

    connection, cursor = get_cursor()

    # Query all categories except specific ones
    cursor.execute("""
        SELECT name FROM product_category 
        WHERE name NOT IN ('Coffee', 'Hot Drinks', 'Milkshakes', 'Iced Teas')
    """)
    categories = cursor.fetchall()
    categories = [row['name'] for row in categories]

    query = """
        SELECT
            product_category.name AS category,
            product.product_id,
            product.name,
            product.unit_price,
            product.description,
            product.is_available,
            product.image,
            inventory.quantity,
            inventory.last_updated,
            staff.first_name AS staff_first_name,
            staff.last_name AS staff_last_name,
            manager.first_name AS manager_first_name,
            manager.last_name AS manager_last_name
        FROM inventory
        LEFT JOIN product ON inventory.product_id = product.product_id
        LEFT JOIN product_category ON product.category_id = product_category.category_id
        LEFT JOIN staff ON inventory.staff_id = staff.staff_id
        LEFT JOIN manager ON inventory.manager_id = manager.manager_id
        WHERE product.is_available = 1
    """

    params = []
    if category_filter:
        query += " AND product_category.name = %s"
        params.append(category_filter)

    query += " ORDER BY product.name LIMIT %s OFFSET %s"
    params.extend([items_per_page, offset])

    cursor.execute(query, params)
    inventory = cursor.fetchall()

    cursor.close()
    connection.close()

    return render_template('staff/staff_inventory.html', staff_info=staff_info, inventory=inventory, 
                           categories=categories, page=page, items_per_page=items_per_page, 
                           category=category_filter, unread_messages=unread_messages)

# Staff update inventory
@staff_blueprint.route('/update_inventory', methods=['POST'])
@role_required(['staff'])
def update_inventory():
    product_id = request.form.get('product_id')
    new_quantity = request.form.get('quantity')
    page = request.form.get('page', 1, type=int)
    category = request.form.get('category', '')
    connection, cursor = get_cursor()

    # Validate new_quantity
    try:
        new_quantity = int(new_quantity)
        if abs(new_quantity) > 100:
            raise ValueError
    except ValueError:
        flash('Invalid quantity. The maximum inventory limit per entry is 100.', 'error')
        return redirect(url_for('staff.monitor_inventory', page=page, category=category)) 

    # Check if the new quantity will make the inventory negative
    cursor.execute("""
        SELECT quantity FROM inventory WHERE product_id = %s
    """, (product_id,))

    current_quantity = cursor.fetchone()
    if current_quantity is None:
        flash('Product not found in inventory.', 'error')
        return redirect(url_for('staff.monitor_inventory', page=page, category=category))

    current_quantity = current_quantity['quantity']
    if current_quantity + new_quantity < 0:
        flash('Invalid quantity. The new quantity cannot make the inventory negative.', 'error')
        return redirect(url_for('staff.monitor_inventory', page=page, category=category))

    cursor.execute("""
        UPDATE inventory
        SET quantity = quantity + %s
        WHERE product_id = %s
    """, (new_quantity, product_id))

    connection.commit()
    cursor.close()
    connection.close()

    return redirect(url_for('staff.monitor_inventory', page=page, category=category))

#check in daily bookings
@staff_blueprint.route('/staff_checkin', methods=['GET', 'POST'])
@role_required(['staff'])
def view_checkin_bookings():
    connection, cursor = get_cursor()
    email = session.get('email')
    staff_info = get_staff_info(email)
    unread_messages = get_unread_messages_for_staff(staff_info['staff_id'])

    if request.method == 'POST':
        selected_date = request.form.get('selected_date')
        selected_date = datetime.strptime(selected_date, '%Y-%m-%d').date()
    else:
        selected_date = datetime.now().date()

    cursor.execute('''
        SELECT b.booking_id, b.start_date, b.end_date, b.status, b.is_paid, 
               c.first_name, c.last_name, c.phone_number, c.date_of_birth, c.id_num,
               a.type AS accommodation_type, b.adults, b.children, 
               (SELECT SUM(p.paid_amount) FROM payment p WHERE p.booking_id = b.booking_id) AS paid_amount
        FROM booking b
        INNER JOIN customer c ON b.customer_id = c.customer_id
        INNER JOIN accommodation a ON b.accommodation_id = a.accommodation_id
        WHERE b.start_date = %s AND b.status = 'confirmed'
    ''', (selected_date,))
    bookings = cursor.fetchall()
    cursor.close()
    connection.close()

    return render_template('staff/staff_checkin.html', bookings=bookings, selected_date=selected_date, staff_info=staff_info,
                           unread_messages=unread_messages)


@staff_blueprint.route('/update_booking/<int:booking_id>', methods=['GET', 'POST'])
@role_required(['staff'])
def update_booking(booking_id):
    connection, cursor = get_cursor()
    
    # Fetch booking details along with customer and accommodation details
    cursor.execute('''
        SELECT b.booking_id, c.first_name, c.last_name, c.phone_number, c.date_of_birth, c.id_num, 
               b.start_date, b.end_date, b.is_paid, b.status, a.type AS accommodation_type
        FROM booking b
        JOIN customer c ON b.customer_id = c.customer_id
        JOIN accommodation a ON b.accommodation_id = a.accommodation_id
        WHERE b.booking_id = %s
    ''', (booking_id,))
    booking = cursor.fetchone()
    
    if not booking:
        flash('Booking not found.', 'danger')
        return redirect(url_for('staff.view_checkin_bookings'))
    
    email = session.get('email')
    staff_info = get_staff_info(email)
    unread_messages = get_unread_messages_for_staff(staff_info['staff_id'])
    today = datetime.today().date()
    
    original_duration = (booking['end_date'] - booking['start_date']).days
    
    if request.method == 'POST':
        # Update customer info
        first_name = request.form.get('first_name')
        last_name = request.form.get('last_name')
        phone_number = request.form.get('phone_number')
        date_of_birth = request.form.get('date_of_birth')
        id_num = request.form.get('id_num')
        start_date = datetime.strptime(request.form.get('start_date'), '%Y-%m-%d').date()
        end_date = booking['end_date']  # Checkout date remains fixed
        check_in = request.form.get('check_in') == 'on'
        
# Validate the dates
        if start_date < today:
            flash('Check-in date cannot be earlier than today.', 'danger')
            return redirect(url_for('staff.update_booking', booking_id=booking_id))
        
        new_duration = (end_date - start_date).days
        if new_duration > original_duration:
            flash('The new check-in date cannot extend the total nights beyond the original booking duration.', 'danger')
            return redirect(url_for('staff.update_booking', booking_id=booking_id))
        
        cursor.execute('''
            UPDATE customer
            SET first_name = %s, last_name = %s, phone_number = %s, date_of_birth = %s, id_num = %s
            WHERE customer_id = (SELECT customer_id FROM booking WHERE booking_id = %s)
        ''', (first_name, last_name, phone_number, date_of_birth, id_num, booking_id))
        
# Validate date of birth
        try:
            new_date_of_birth = datetime.strptime(date_of_birth, '%Y-%m-%d').date()
            today = date.today()
            age = today.year - new_date_of_birth.year - ((today.month, today.day) < (new_date_of_birth.month, new_date_of_birth.day))
        except ValueError:
            flash("Invalid date format for date of birth.", "danger")
            return redirect(url_for('staff.update_booking', booking_id=booking_id))

        if age < 18:
            flash("Customer must be over 18 years old.", "danger")
            cursor.close()
            connection.close()
            return redirect(url_for('staff.update_booking', booking_id=booking_id))
        
        cursor.execute('''
            UPDATE customer
            SET first_name = %s, last_name = %s, phone_number = %s, date_of_birth = %s, id_num = %s
            WHERE customer_id = (SELECT customer_id FROM booking WHERE booking_id = %s)
        ''', (first_name, last_name, phone_number, new_date_of_birth, id_num, booking_id))
        
# Update booking info
        new_status = 'checked in' if check_in and start_date <= today else booking['status']
        cursor.execute('''
            UPDATE booking
            SET start_date = %s, end_date = %s, status = %s
            WHERE booking_id = %s
        ''', (start_date, end_date, new_status, booking_id))
        
        connection.commit()
        cursor.close()
        connection.close()
        
        flash('Booking updated successfully.', 'success')
        return redirect(url_for('staff.view_checkin_bookings'))
    
    return render_template('staff/staff_updatebooking.html', booking=booking, staff_info=staff_info, today=today,
                           unread_messages=unread_messages)


#view all bookings
@staff_blueprint.route('/staff_view_all_bookings', methods=['GET'])
@role_required(['staff'])
def view_all_bookings():
    connection, cursor = get_cursor()
    email = session.get('email')
    staff_info = get_staff_info(email)
    unread_messages = get_unread_messages_for_staff(staff_info['staff_id'])
    today = datetime.now().date()
    
    cursor.execute('''
        SELECT b.booking_id, b.start_date, b.end_date, b.status, b.is_paid, 
               c.first_name, c.last_name, c.phone_number, c.date_of_birth, c.id_num,
               a.type AS accommodation_type, a.capacity, a.price_per_night,
               b.adults, b.children,
               (SELECT SUM(p.paid_amount) FROM payment p WHERE p.booking_id = b.booking_id) AS paid_amount
        FROM booking b
        INNER JOIN customer c ON b.customer_id = c.customer_id
        INNER JOIN accommodation a ON b.accommodation_id = a.accommodation_id
        WHERE b.status = 'confirmed' AND b.end_date >= %s
        ORDER BY b.start_date ASC
    ''', (today,))
    bookings = cursor.fetchall()
    cursor.close()
    connection.close()

    return render_template('staff/staff_view_all_bookings.html', title='All Confirmed Bookings', 
                           bookings=bookings, staff_info=staff_info, unread_messages=unread_messages)


@staff_blueprint.route('/view_all_no_show_bookings', methods=['GET'])
@role_required(['staff'])
def view_all_no_show_bookings():
    connection, cursor = get_cursor()
    email = session.get('email')
    staff_info = get_staff_info(email)
    unread_messages = get_unread_messages_for_staff(staff_info['staff_id'])
    today = datetime.now().date()

    cursor.execute('''
        SELECT b.booking_id, b.start_date, b.end_date, b.status, b.is_paid, 
               c.first_name, c.last_name, c.phone_number, c.date_of_birth, c.id_num,
               a.type AS accommodation_type, a.capacity, a.price_per_night,
               b.adults, b.children,
               (SELECT SUM(p.paid_amount) FROM payment p WHERE p.booking_id = b.booking_id) AS paid_amount
        FROM booking b
        INNER JOIN customer c ON b.customer_id = c.customer_id
        INNER JOIN accommodation a ON b.accommodation_id = a.accommodation_id
        WHERE b.status = 'confirmed' AND b.end_date < %s
        ORDER BY b.start_date DESC
    ''', (today,))
    bookings = cursor.fetchall()

    # Update the status to 'No Show'
    for booking in bookings:
        booking['status'] = 'no show'

    cursor.close()
    connection.close()

    return render_template('staff/staff_view_all_bookings.html', title='All No Show Bookings', 
                           bookings=bookings, staff_info=staff_info, unread_messages=unread_messages)




@staff_blueprint.route('/view_all_cancelled_bookings', methods=['GET'])
@role_required(['staff'])
def view_all_cancelled_bookings():
    connection, cursor = get_cursor()
    email = session.get('email')
    staff_info = get_staff_info(email)
    unread_messages = get_unread_messages_for_staff(staff_info['staff_id'])

    cursor.execute('''
        SELECT b.booking_id, b.start_date, b.end_date, b.status, b.is_paid, 
               c.first_name, c.last_name, c.phone_number, c.date_of_birth, c.id_num,
               a.type AS accommodation_type, a.capacity, a.price_per_night,
               b.adults, b.children,
               (SELECT SUM(p.paid_amount) FROM payment p WHERE p.booking_id = b.booking_id) AS paid_amount
        FROM booking b
        INNER JOIN customer c ON b.customer_id = c.customer_id
        INNER JOIN accommodation a ON b.accommodation_id = a.accommodation_id
        WHERE b.status = 'cancelled'
        ORDER BY b.start_date DESC
    ''')
    bookings = cursor.fetchall()
    cursor.close()
    connection.close()

    return render_template('staff/staff_view_all_bookings.html', bookings=bookings, staff_info=staff_info, 
                           title='All Cancelled Bookings', unread_messages=unread_messages)


@staff_blueprint.route('/view_all_checked_out_bookings', methods=['GET'])
@role_required(['staff'])
def view_all_checked_out_bookings():
    connection, cursor = get_cursor()
    email = session.get('email')
    staff_info = get_staff_info(email)
    unread_messages = get_unread_messages_for_staff(staff_info['staff_id'])

    cursor.execute('''
        SELECT b.booking_id, b.start_date, b.end_date, b.status, b.is_paid, 
               c.first_name, c.last_name, c.phone_number, c.date_of_birth, c.id_num,
               a.type AS accommodation_type, a.capacity, a.price_per_night,
               b.adults, b.children,
               (SELECT SUM(p.paid_amount) FROM payment p WHERE p.booking_id = b.booking_id) AS paid_amount
        FROM booking b
        INNER JOIN customer c ON b.customer_id = c.customer_id
        INNER JOIN accommodation a ON b.accommodation_id = a.accommodation_id
        WHERE b.status = 'checked out'
        ORDER BY b.start_date DESC
    ''')
    bookings = cursor.fetchall()
    cursor.close()
    connection.close()

    return render_template('staff/staff_view_all_bookings.html', bookings=bookings, staff_info=staff_info, 
                           title='All Checked Out Bookings', unread_messages=unread_messages)


@staff_blueprint.route('/view_all_checked_in_bookings', methods=['GET'])
@role_required(['staff'])
def view_all_checked_in_bookings():
    connection, cursor = get_cursor()
    email = session.get('email')
    staff_info = get_staff_info(email)
    unread_messages = get_unread_messages_for_staff(staff_info['staff_id'])

    cursor.execute('''
        SELECT b.booking_id, b.start_date, b.end_date, b.status, b.is_paid, 
               c.first_name, c.last_name, c.phone_number, c.date_of_birth, c.id_num,
               a.type AS accommodation_type, a.capacity, a.price_per_night,
               b.adults, b.children,
               (SELECT SUM(p.paid_amount) FROM payment p WHERE p.booking_id = b.booking_id) AS paid_amount
        FROM booking b
        INNER JOIN customer c ON b.customer_id = c.customer_id
        INNER JOIN accommodation a ON b.accommodation_id = a.accommodation_id
        WHERE b.status = 'checked in'
        ORDER BY b.start_date DESC
    ''')
    bookings = cursor.fetchall()
    cursor.close()
    connection.close()

    return render_template('staff/staff_view_all_bookings.html', bookings=bookings, staff_info=staff_info, 
                           title='All Checked In Bookings', unread_messages=unread_messages)

#search bookings by last name and booking ID
@staff_blueprint.route('/search_bookings', methods=['GET'])
@role_required(['staff'])
def search_bookings():
    search_query = request.args.get('search_query')
    
    if not search_query:
        flash('Please enter a last name or booking ID to search.', 'warning')
        return redirect(url_for('staff.view_all_bookings'))

    connection, cursor = get_cursor()
    email = session.get('email')
    staff_info = get_staff_info(email)
    unread_messages = get_unread_messages_for_staff(staff_info['staff_id'])
    today = datetime.now().date()

    # Determine if search_query is a booking ID or a last name  
    if search_query.isdigit():
        cursor.execute('''
            SELECT b.booking_id, b.start_date, b.end_date, b.status, b.is_paid,
                   c.first_name, c.last_name, c.phone_number, c.date_of_birth, c.id_num,
                   a.type AS accommodation_type, a.capacity, a.price_per_night,
                   (SELECT SUM(p.paid_amount) FROM payment p WHERE p.booking_id = b.booking_id) AS paid_amount,
                   b.adults, b.children
            FROM booking b
            INNER JOIN customer c ON b.customer_id = c.customer_id
            INNER JOIN accommodation a ON b.accommodation_id = a.accommodation_id
            WHERE b.booking_id = %s
            ORDER BY b.start_date DESC
        ''', (search_query,))
    else:
        cursor.execute('''
            SELECT b.booking_id, b.start_date, b.end_date, b.status, b.is_paid,
                   c.first_name, c.last_name, c.phone_number, c.date_of_birth, c.id_num,
                   a.type AS accommodation_type, a.capacity, a.price_per_night,
                   (SELECT SUM(p.paid_amount) FROM payment p WHERE p.booking_id = b.booking_id) AS paid_amount,
                   b.adults, b.children
            FROM booking b
            INNER JOIN customer c ON b.customer_id = c.customer_id
            INNER JOIN accommodation a ON b.accommodation_id = a.accommodation_id
            WHERE c.last_name LIKE %s
            ORDER BY b.start_date DESC
        ''', (f'%{search_query}%',))
    
    bookings = cursor.fetchall()

    # Update the status to 'No Show' if the end date is in the past and the status is 'confirmed'
    for booking in bookings:
        if booking['status'] == 'confirmed' and booking['end_date'] < today:
            booking['status'] = 'no show'

    cursor.close()
    connection.close()

    return render_template('staff/staff_view_all_bookings.html', title="Search Results", bookings=bookings, 
                           staff_info=staff_info, unread_messages=unread_messages)


#staff checkout bookings
@staff_blueprint.route('/staff_checkout_booking', methods=["GET", "POST"])
@role_required(['staff'])
def view_checked_in_bookings():
    connection, cursor = get_cursor()
    email = session.get('email')
    staff_info = get_staff_info(email)
    unread_messages = get_unread_messages_for_staff(staff_info['staff_id'])

    cursor.execute('''
        SELECT b.booking_id, b.start_date, b.end_date, b.status, b.is_paid, 
               c.first_name, c.last_name, c.phone_number, c.date_of_birth, c.id_num,
               a.type AS accommodation_type, a.capacity, a.price_per_night,
               b.adults, b.children,
               (SELECT SUM(p.paid_amount) FROM payment p WHERE p.booking_id = b.booking_id) AS paid_amount
        FROM booking b
        INNER JOIN customer c ON b.customer_id = c.customer_id
        INNER JOIN accommodation a ON b.accommodation_id = a.accommodation_id
        WHERE b.status = 'checked in'
        ORDER BY b.end_date DESC
    ''')
    bookings = cursor.fetchall()
    cursor.close()
    connection.close()
    return render_template('staff/staff_checkout_booking.html', bookings=bookings, staff_info=staff_info, 
                           title='All Checked In Bookings', unread_messages=unread_messages)

@staff_blueprint.route('/checkout_booking/<int:booking_id>', methods=['POST'])
@role_required(['staff'])
def checkout_booking(booking_id):
    connection, cursor = get_cursor()
    cursor.execute('''
        UPDATE booking
        SET status = 'checked out'
        WHERE booking_id = %s
    ''', (booking_id,))
    connection.commit()
    cursor.close()
    connection.close()
    flash('Booking checked out successfully.', 'success')
    return redirect(url_for('staff.view_checked_in_bookings'))

#staff cancel bookings
@staff_blueprint.route('/staff_cancelbooking', methods=["GET", "POST"])
@role_required(['staff'])
def view_confirmed_bookings():
    connection, cursor = get_cursor()
    email = session.get('email')
    today = datetime.now().date()
    staff_info = get_staff_info(email)
    unread_messages = get_unread_messages_for_staff(staff_info['staff_id'])

    search_term = request.args.get('search_term', '')
    cursor.execute('''
        SELECT b.booking_id, b.start_date AS check_in_date, b.end_date AS check_out_date, b.status, b.is_paid, 
               CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
               a.type AS accommodation_type, a.capacity, a.price_per_night,
               b.adults, b.children, b.booking_date,
               (SELECT SUM(p.paid_amount) FROM payment p WHERE p.booking_id = b.booking_id) AS paid_amount
        FROM booking b
        INNER JOIN customer c ON b.customer_id = c.customer_id
        INNER JOIN accommodation a ON b.accommodation_id = a.accommodation_id
        WHERE b.status = 'confirmed' AND b.end_date >= %s AND (b.booking_id = %s OR c.first_name LIKE %s OR c.last_name LIKE %s)
        ORDER BY b.end_date DESC
    ''', (today, search_term, f'%{search_term}%', f'%{search_term}%'))
    bookings = cursor.fetchall()
    cursor.close()
    connection.close()
    return render_template('staff/staff_cancelbooking.html', bookings=bookings, staff_info=staff_info, 
                           title='All Confirmed Bookings', unread_messages=unread_messages)




@staff_blueprint.route('/cancel_booking/<int:booking_id>', methods=['POST'])
@role_required(['staff'])
def cancel_booking(booking_id):
    connection, cursor = get_cursor()
    cursor.execute('''
        SELECT b.*, a.price_per_night, p.payment_type_id, p.paid_amount, pt.payment_type 
        FROM booking b 
        JOIN accommodation a ON b.accommodation_id = a.accommodation_id
        JOIN payment p ON b.booking_id = p.booking_id
        JOIN payment_type pt ON p.payment_type_id = pt.payment_type_id
        WHERE b.booking_id = %s
    ''', (booking_id,))
    booking = cursor.fetchall()
    cursor.close()

    if not booking:
        connection.close()
        flash('Booking not found.', 'error')
        return redirect(url_for('staff.staff_cancelbooking'))

    booking = booking[0]  # Get the first result

    # Calculate refund amount
    payment_type_id = booking['payment_type_id']
    paid_amount = booking['paid_amount']
    payment_type_name = booking['payment_type']
    price_per_night = booking['price_per_night']
    start_date = booking['start_date']
    end_date = booking['end_date']
    customer_id= booking['customer_id']
    nights = (end_date - start_date).days
    refund_amount = calculate_refund_amount(price_per_night, nights, start_date, paid_amount)
    
    # insert negative payment entry only if there's a refund
    if refund_amount > 0:
        if payment_type_name == 'gift_card':
            cursor = connection.cursor()
            cursor.execute('UPDATE gift_card SET balance = balance + %s WHERE gift_card_id = %s', 
                           (refund_amount, booking['payment_id']))
            cursor.close()
        elif payment_type_name == 'bank_card':
            cursor = connection.cursor()
            cursor.execute('''
                INSERT INTO payment (customer_id, booking_id, payment_type_id, paid_amount)
                VALUES (%s, %s, %s, %s)
            ''', (customer_id, booking_id, payment_type_id, -refund_amount))
            cursor.close()

    # Update the booking status to cancelled
    cursor = connection.cursor()
    cursor.execute('''
        UPDATE booking 
        SET status = 'cancelled' 
        WHERE booking_id = %s
    ''', (booking_id,))
    cursor.close()
    
    # Remove blocked dates
    cursor = connection.cursor()
    cursor.execute('''
        DELETE FROM blocked_dates 
        WHERE accommodation_id = %s AND start_date = %s AND end_date = %s
    ''', (booking['accommodation_id'], start_date, end_date))
    cursor.close()

    connection.commit()
    connection.close()


    payment_type_name = payment_type_name.replace('_', ' ').title()

    if refund_amount > 0:
        flash(f'Booking cancelled and ${refund_amount} refunded to {payment_type_name}.', 'success')
    else:
        flash(f'Booking cancelled but no refund as per the cancellation policy.', 'info')
    return redirect(url_for('staff.view_confirmed_bookings', booking_id=booking_id))


def calculate_refund_amount(price_per_night, nights, start_date, paid_amount):
    today = datetime.now().date()
    days_to_start = (start_date - today).days

    # Refund policy
    if days_to_start >= 1:
        return paid_amount  # Full refund
    else:
        return 0 #no refund

# Chat room for staff
def get_chat_history_for_staff_and_customer(customer_id):
    connection, cursor = get_cursor()
    cursor.execute("""
        SELECT content, sent_at, sender_type, staff_id, manager_id, customer_id
        FROM message
        WHERE customer_id = %s
        ORDER BY sent_at ASC
    """, (customer_id,))
    messages = cursor.fetchall()
    cursor.close()
    connection.close()
    return messages

@staff_blueprint.route('/chat/<int:customer_id>')
@role_required(['staff'])
def staff_chat(customer_id):
    email = session.get('email')
    staff_info = get_staff_info(email)
    customer_info = get_customer_info_by_id(customer_id)
    unread_messages = get_unread_messages_for_staff(staff_info['staff_id'])
    chat_history = get_chat_history_for_staff_and_customer(customer_id)
    return render_template('staff/staff_chat.html', staff_info=staff_info, customer_info=customer_info, 
                           chat_history=chat_history, unread_messages=unread_messages)

@staff_blueprint.route('/customers')
@role_required(['staff'])
def list_customers():
    page = request.args.get('page', 1, type=int)
    per_page = 10  
    offset = (page - 1) * per_page

    connection, cursor = get_cursor()
    cursor.execute("SELECT COUNT(*) FROM customer WHERE status = 'active'")
    result = cursor.fetchone()
    total_customers = result['COUNT(*)'] if result else 0
    total_pages = (total_customers + per_page - 1) // per_page

    cursor.execute("SELECT customer_id, first_name, last_name FROM customer WHERE status = 'active' ORDER BY customer_id LIMIT %s OFFSET %s", (per_page, offset))
    customers = cursor.fetchall()
    cursor.close()
    connection.close()

    return render_template('staff/staff_list_customers.html', customers=customers, staff_info=get_staff_info(session.get('email')),
                           unread_messages=get_unread_messages_for_staff(get_staff_info(session.get('email'))['staff_id']),
                           page=page, total_pages=total_pages)

@socketio.on('message', namespace='/staff')
def handle_message_staff(data):
    user_id = data.get('user_id')
    message = data.get('message')
    room = data.get('room')
    
    staff_id = user_id
    customer_id = data.get('partner_id')
    
    connection, cursor = get_cursor()
    try:
        cursor.execute("""
            INSERT INTO message (customer_id, staff_id, sender_type, content, sent_at) VALUES (%s, %s, 'staff', %s, NOW())
        """, (customer_id, staff_id, message))
        connection.commit()

        cursor.execute("SELECT sent_at FROM message WHERE message_id = LAST_INSERT_ID()")
        sent_at = cursor.fetchone()['sent_at']
    except Exception as e:
        print(f"Error saving message: {e}")
        connection.rollback()
    finally:
        cursor.close()
        connection.close()
    
    if room:
        send({
            'message': message,
            'user_type': 'staff',
            'username': 'Staff',
            'sent_at': sent_at.strftime('%d-%m-%Y %H:%M:%S')
        }, to=room, namespace='/staff')

@staff_blueprint.route('/chat_history/<int:customer_id>')
@role_required(['staff'])
def get_chat_history_staff(customer_id):
    email = session.get('email')
    staff_info = get_staff_info(email)
    staff_id = staff_info['staff_id']

    messages = get_chat_history_for_staff_and_customer(customer_id)

    return jsonify(messages)
