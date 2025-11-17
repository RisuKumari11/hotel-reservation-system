from flask import Flask, render_template, request, session, redirect, url_for, jsonify
import mysql.connector
from mysql.connector import Error
from datetime import datetime, timedelta

app = Flask(__name__)
app.secret_key = 'hotel_management_secret_key_2025'

# Database Configuration
db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': 'sanjana',  # CHANGE THIS TO YOUR MYSQL PASSWORD
    'database': 'Hotel_Management_System'
}

def get_db_connection():
    """Create database connection"""
    try:
        conn = mysql.connector.connect(**db_config)
        return conn
    except Error as e:
        print(f"Database connection failed: {e}")
        return None

# ============================================
# DATABASE FUNCTIONS
# ============================================

def verify_admin_login(username, password):
    """Verify admin credentials"""
    conn = get_db_connection()
    if conn:
        cursor = conn.cursor(dictionary=True)
        try:
            cursor.execute("""SELECT a_username, a_email 
                            FROM Administrator 
                            WHERE a_username = %s AND a_pwd = %s""", 
                          (username, password))
            admin = cursor.fetchone()
            
            if admin:
                if 'taj' in username.lower():
                    hotel_id = 1
                elif 'oberoi' in username.lower():
                    hotel_id = 2
                elif 'leela' in username.lower():
                    hotel_id = 3
                elif 'itc' in username.lower():
                    hotel_id = 4
                elif 'radisson' in username.lower():
                    hotel_id = 5
                elif 'hilton' in username.lower():
                    hotel_id = 6
                elif 'marriott' in username.lower():
                    hotel_id = 7
                elif 'hyatt' in username.lower():
                    hotel_id = 8
                else:
                    hotel_id = None
                
                admin['hotel_id'] = hotel_id
                return admin
            return None
        except Error as e:
            print(f"Error: {e}")
        finally:
            conn.close()
    return None

def create_or_get_guest(name, email, phone, city, state):
    """Create guest if doesn't exist, or return existing guest"""
    conn = get_db_connection()
    if conn:
        cursor = conn.cursor(dictionary=True)
        try:
            cursor.execute("SELECT * FROM Guest WHERE g_email = %s", (email,))
            guest = cursor.fetchone()
            
            if guest:
                conn.close()
                return guest
            
            cursor.execute("SELECT MAX(g_id) as max_id FROM Guest")
            result = cursor.fetchone()
            new_id = (result['max_id'] or 0) + 1
            
            cursor.execute("""INSERT INTO Guest (g_id, g_name, g_email, g_number, g_city, g_state)
                            VALUES (%s, %s, %s, %s, %s, %s)""",
                          (new_id, name, email, phone, city, state))
            conn.commit()
            
            cursor.execute("SELECT * FROM Guest WHERE g_email = %s", (email,))
            new_guest = cursor.fetchone()
            conn.close()
            return new_guest
        except Error as e:
            print(f"Error: {e}")
            conn.close()
    return None

def get_all_hotels():
    """Get all hotels"""
    conn = get_db_connection()
    if conn:
        cursor = conn.cursor(dictionary=True)
        try:
            cursor.execute("SELECT h_id, h_name FROM Hotel ORDER BY h_id")
            result = cursor.fetchall()
            conn.close()
            return result
        except Error as e:
            print(f"Error: {e}")
            conn.close()
    return []

def get_available_rooms(hotel_id):
    """Get available rooms in a hotel"""
    conn = get_db_connection()
    if conn:
        cursor = conn.cursor(dictionary=True)
        try:
            cursor.execute("""
                SELECT r.r_id, r.r_number, r.r_price, rt.room_name, rt.max_guests
                FROM Room r
                JOIN Room_Type rt ON r.r_type_id = rt.room_type_id
                WHERE r.hotel_id = %s AND r.r_status = 'Available'
            """, (hotel_id,))
            result = cursor.fetchall()
            conn.close()
            return result
        except Error as e:
            print(f"Error: {e}")
            conn.close()
    return []

def get_guest_reservations(guest_id):
    """Get reservations for a guest"""
    conn = get_db_connection()
    if conn:
        cursor = conn.cursor(dictionary=True)
        try:
            cursor.execute("""
                SELECT r.reservation_id, r.check_in_date, r.check_out_date, 
                       r.booking_date, r.reservation_status, rm.r_number, h.h_name
                FROM Reservation r
                LEFT JOIN Reserved_By rb ON r.reservation_id = rb.reservation_id
                LEFT JOIN Room rm ON rb.r_id = rm.r_id
                LEFT JOIN Hotel h ON rm.hotel_id = h.h_id
                WHERE r.guest_id = %s
                ORDER BY r.check_in_date DESC
            """, (guest_id,))
            result = cursor.fetchall()
            conn.close()
            return result
        except Error as e:
            print(f"Error: {e}")
            conn.close()
    return []

def book_room(guest_id, room_id, checkin, checkout):
    """Book a room"""
    conn = get_db_connection()
    if conn:
        cursor = conn.cursor()
        try:
            cursor.execute("SELECT MAX(reservation_id) as max_id FROM Reservation")
            result = cursor.fetchone()
            new_res_id = (result[0] or 1000) + 1
            
            cursor.execute("""INSERT INTO Reservation (reservation_id, guest_id, check_in_date, check_out_date, booking_date, reservation_status)
                            VALUES (%s, %s, %s, %s, %s, 'Booked')""",
                          (new_res_id, guest_id, checkin, checkout, datetime.now().date()))
            
            cursor.execute("""INSERT INTO Reserved_By (r_id, reservation_id)
                            VALUES (%s, %s)""",
                          (room_id, new_res_id))
            
            cursor.execute("UPDATE Room SET r_status = 'Booked' WHERE r_id = %s", (room_id,))
            
            conn.commit()
            conn.close()
            return True
        except Error as e:
            print(f"Booking failed: {e}")
            conn.rollback()
            conn.close()
            return False
    return False

def cancel_reservation(reservation_id):
    """Cancel a reservation"""
    conn = get_db_connection()
    if conn:
        cursor = conn.cursor()
        try:
            cursor.execute("CALL sp_CancelReservation(%s)", (reservation_id,))
            conn.commit()
            conn.close()
            return True
        except Error as e:
            print(f"Cancellation failed: {e}")
            conn.close()
            return False
    return False

def process_payment(guest_id, reservation_id, amount, method):
    """Process payment"""
    conn = get_db_connection()
    if conn:
        cursor = conn.cursor()
        try:
            cursor.execute("SELECT MAX(payment_id) as max_id FROM Payment")
            result = cursor.fetchone()
            new_payment_id = (result[0] or 0) + 1
            
            cursor.execute("""INSERT INTO Payment (payment_id, g_id, reservation_id, payment_amount, payment_method, payment_date)
                            VALUES (%s, %s, %s, %s, %s, %s)""",
                          (new_payment_id, guest_id, reservation_id, amount, method, datetime.now().date()))
            
            conn.commit()
            conn.close()
            return True
        except Error as e:
            print(f"Payment failed: {e}")
            conn.close()
            return False
    return False

def get_hotel_reservations(hotel_id):
    """Get all reservations for a hotel (admin view)"""
    conn = get_db_connection()
    if conn:
        cursor = conn.cursor(dictionary=True)
        try:
            cursor.execute("""
                SELECT r.reservation_id, g.g_name, g.g_email, r.check_in_date, 
                       r.check_out_date, r.reservation_status, rm.r_number, h.h_name
                FROM Reservation r
                JOIN Guest g ON r.guest_id = g.g_id
                LEFT JOIN Reserved_By rb ON r.reservation_id = rb.reservation_id
                LEFT JOIN Room rm ON rb.r_id = rm.r_id
                LEFT JOIN Hotel h ON rm.hotel_id = h.h_id
                WHERE h.h_id = %s
                ORDER BY r.check_in_date DESC
            """, (hotel_id,))
            result = cursor.fetchall()
            conn.close()
            return result
        except Error as e:
            print(f"Error: {e}")
            conn.close()
    return []

def get_hotel_rooms(hotel_id):
    """Get all rooms for a hotel (admin view)"""
    conn = get_db_connection()
    if conn:
        cursor = conn.cursor(dictionary=True)
        try:
            cursor.execute("""
                SELECT r.r_number, r.r_status, r.r_price, rt.room_name
                FROM Room r
                JOIN Room_Type rt ON r.r_type_id = rt.room_type_id
                WHERE r.hotel_id = %s
            """, (hotel_id,))
            result = cursor.fetchall()
            conn.close()
            return result
        except Error as e:
            print(f"Error: {e}")
            conn.close()
    return []

def get_payment_logs():
    """Get payment logs with room details"""
    conn = get_db_connection()
    if conn:
        cursor = conn.cursor(dictionary=True)
        try:
            cursor.execute("""
                SELECT 
                    pl.log_id, 
                    pl.payment_id, 
                    pl.log_message, 
                    pl.log_time,
                    COALESCE(r.r_number, 'N/A') as room_number,
                    g.g_name as guest_name
                FROM Payment_Log pl
                LEFT JOIN Payment p ON pl.payment_id = p.payment_id
                LEFT JOIN Reservation res ON p.reservation_id = res.reservation_id
                LEFT JOIN Reserved_By rb ON res.reservation_id = rb.reservation_id
                LEFT JOIN Room r ON rb.r_id = r.r_id
                LEFT JOIN Guest g ON res.guest_id = g.g_id
                ORDER BY pl.log_time DESC LIMIT 50
            """)
            result = cursor.fetchall()
            conn.close()
            return result
        except Error as e:
            print(f"Error: {e}")
            conn.close()
    return []

# ============================================
# ROUTES
# ============================================

@app.route('/')
def index():
    if 'logged_in' in session:
        if session.get('is_admin'):
            return redirect(url_for('admin_dashboard'))
        else:
            return redirect(url_for('guest_dashboard'))
    return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        login_type = request.form.get('login_type')
        
        if login_type == 'admin':
            username = request.form.get('admin_user')
            password = request.form.get('admin_pass')
            
            result = verify_admin_login(username, password)
            if result:
                session['logged_in'] = True
                session['is_admin'] = True
                session['username'] = result['a_username']
                session['admin_hotel_id'] = result['hotel_id']
                return redirect(url_for('admin_dashboard'))
            else:
                return render_template('login.html', error='Invalid admin credentials')
        
        else:  # Guest login
            name = request.form.get('guest_name')
            email = request.form.get('guest_email')
            phone = request.form.get('guest_phone')
            city = request.form.get('guest_city')
            state = request.form.get('guest_state')
            
            if name and email:
                guest = create_or_get_guest(name, email, phone, city, state)
                if guest:
                    session['logged_in'] = True
                    session['is_admin'] = False
                    session['guest_id'] = guest['g_id']
                    session['username'] = guest['g_name']
                    return redirect(url_for('guest_dashboard'))
            
            return render_template('login.html', error='Failed to register guest')
    
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

@app.route('/admin/dashboard')
def admin_dashboard():
    if not session.get('logged_in') or not session.get('is_admin'):
        return redirect(url_for('login'))
    
    hotel_id = session.get('admin_hotel_id')
    reservations = get_hotel_reservations(hotel_id)
    rooms = get_hotel_rooms(hotel_id)
    payment_logs = get_payment_logs()
    
    return render_template('admin_dashboard.html',
                         username=session.get('username'),
                         reservations=reservations,
                         rooms=rooms,
                         payment_logs=payment_logs)

@app.route('/guest/dashboard')
def guest_dashboard():
    if not session.get('logged_in') or session.get('is_admin'):
        return redirect(url_for('login'))
    
    guest_id = session.get('guest_id')
    hotels = get_all_hotels()
    reservations = get_guest_reservations(guest_id)
    
    return render_template('guest_dashboard.html',
                         username=session.get('username'),
                         hotels=hotels,
                         reservations=reservations)

@app.route('/api/available-rooms/<int:hotel_id>')
def api_available_rooms(hotel_id):
    rooms = get_available_rooms(hotel_id)
    return jsonify(rooms)

@app.route('/api/reservation-details/<int:reservation_id>')
def api_reservation_details(reservation_id):
    """Get room details for a reservation"""
    conn = get_db_connection()
    if conn:
        cursor = conn.cursor(dictionary=True)
        try:
            cursor.execute("""
                SELECT r.r_price, rt.room_name
                FROM Room r
                JOIN Reserved_By rb ON r.r_id = rb.r_id
                JOIN Room_Type rt ON r.r_type_id = rt.room_type_id
                WHERE rb.reservation_id = %s
            """, (reservation_id,))
            result = cursor.fetchone()
            conn.close()
            if result:
                return jsonify(result)
            return jsonify({'r_price': 0, 'room_name': 'N/A'})
        except Error as e:
            print(f"Error: {e}")
            conn.close()
    return jsonify({'r_price': 0, 'room_name': 'N/A'})

@app.route('/book-room', methods=['POST'])
def book_room_route():
    guest_id = session.get('guest_id')
    room_id = request.form.get('room_id')
    checkin = request.form.get('checkin_date')
    checkout = request.form.get('checkout_date')
    
    if book_room(guest_id, room_id, checkin, checkout):
        pass
    return redirect(url_for('guest_dashboard'))

@app.route('/cancel-reservation/<int:res_id>', methods=['GET', 'POST'])
def cancel_reservation_route(res_id):
    if cancel_reservation(res_id):
        pass
    return redirect(url_for('guest_dashboard'))

@app.route('/make-payment', methods=['POST'])
def make_payment():
    guest_id = session.get('guest_id')
    reservation_id = request.form.get('reservation_id')
    amount = float(request.form.get('amount'))
    method = request.form.get('method')
    
    if process_payment(guest_id, reservation_id, amount, method):
        pass
    return redirect(url_for('guest_dashboard'))

if __name__ == '__main__':
    app.run(debug=True, port=5000)