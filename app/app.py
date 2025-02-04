from flask import Flask, request, render_template_string, redirect, url_for, jsonify
import psycopg2
from werkzeug.middleware.proxy_fix import ProxyFix
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)

# If behind a reverse proxy, use ProxyFix
app.wsgi_app = ProxyFix(app.wsgi_app, x_for=1, x_proto=1, x_host=1, x_port=1)

metrics = PrometheusMetrics(app, path='/metrics')

def get_db_connection():
    conn = psycopg2.connect(
        dbname="registration_db",
        user="admin",
        password="adminpass",
        host="postgres"
    )
    return conn

def init_db():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id SERIAL PRIMARY KEY,
            username VARCHAR(255) UNIQUE NOT NULL,
            password VARCHAR(255) NOT NULL
        );
    """)
    conn.commit()
    cur.close()
    conn.close()

@app.route("/")
def index():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT username, password FROM users;")
    users = cur.fetchall()
    cur.close()
    conn.close()
    html = """
    <html>
      <head>
        <title>User Registration</title>
        <style>
          .scrollable-table {
            height: 300px;
            overflow-y: auto;
            border: 1px solid #ccc;
            margin-top: 10px;
          }
          table {
            width: 100%;
            border-collapse: collapse;
          }
          th, td {
            padding: 8px;
            text-align: left;
            border: 1px solid #ddd;
          }
          th {
            background-color: #f2f2f2;
          }
        </style>
      </head>
      <body>
        <!-- New: Application Details Section -->
        <h2>Application Details</h2>
        <p>
          This Docker-based application uses Postgres, Nginx, Prometheus, and Grafana for a complete stack:
          <ul>
            <li><strong><a href="/metrics">/metrics</a></strong> - Flask endpoint exposing Prometheus metrics.</li>
            <li><strong><a href="/prometheus">/prometheus</a></strong> - Prometheus UI to view and query scraped data.</li>
            <li><strong><a href="/grafana">/grafana</a></strong> - Grafana UI for advanced dashboards and visualizations.</li>
          </ul>
          The main functionality below is a simple user registration system backed by PostgreSQL.
        </p>
        <hr/>
        
        <h1>User Registration</h1>
        <form method="POST" action="/register">
          <label>Username:</label>
          <input type="text" name="reg_username" required/><br/><br/>
          <label>Password:</label>
          <input type="password" name="reg_password" required/><br/><br/>
          <input type="submit" value="Register"/>
        </form>
        <hr/>
        <h2>Registered Users</h2>
        <div class="scrollable-table">
          {% if users %}
            <table cellpadding="5" cellspacing="0">
              <thead>
                <tr>
                  <th>Username</th>
                  <th>Password</th>
                  <th>Action</th>
                </tr>
              </thead>
              <tbody>
                {% for user in users %}
                <tr>
                  <td>{{ user[0] }}</td>
                  <td>{{ user[1] }}</td>
                  <td>
                    <form method="POST" action="/delete" onsubmit="return confirm('Delete user {{ user[0] }}?');">
                      <input type="hidden" name="del_username" value="{{ user[0] }}"/>
                      <input type="submit" value="Delete"/>
                    </form>
                  </td>
                </tr>
                {% endfor %}
              </tbody>
            </table>
          {% else %}
            <p>No users registered yet.</p>
          {% endif %}
        </div>
      </body>
    </html>
    """
    return render_template_string(html, users=users)

@app.route("/register", methods=["POST"])
def register():
    reg_username = request.form.get("reg_username")
    reg_password = request.form.get("reg_password")
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute("INSERT INTO users (username, password) VALUES (%s, %s);", (reg_username, reg_password))
        conn.commit()
    except Exception as e:
        conn.rollback()
        print("Error registering user:", e)
    finally:
        cur.close()
        conn.close()
    return redirect(url_for("index"))

@app.route("/delete", methods=["POST"])
def delete():
    del_username = request.form.get("del_username")
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute("DELETE FROM users WHERE username = %s;", (del_username,))
        conn.commit()
    except Exception as e:
        conn.rollback()
        print("Error deleting user:", e)
    finally:
        cur.close()
        conn.close()
    return redirect(url_for("index"))

if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=5000, debug=False, use_reloader=False)
