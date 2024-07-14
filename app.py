from flask import Flask
from auth import auth_blueprint
from guest import guest_blueprint
from manager import manager_blueprint
from staff import staff_blueprint
from customer import customer_blueprint
from config import format_date, format_time
from extensions import socketio, hashing

app = Flask(__name__)

# Register the custom filter
app.jinja_env.filters['format_date'] = format_date
app.jinja_env.filters['format_time'] = format_time

app.secret_key = 'Group ZZ'

hashing.init_app(app)
socketio.init_app(app)

app.register_blueprint(auth_blueprint)
app.register_blueprint(guest_blueprint)
app.register_blueprint(manager_blueprint, url_prefix='/manager')
app.register_blueprint(staff_blueprint, url_prefix='/staff')
app.register_blueprint(customer_blueprint, url_prefix='/customer')

if __name__ == '__main__':
    socketio.run(app, debug=True)
    
    
