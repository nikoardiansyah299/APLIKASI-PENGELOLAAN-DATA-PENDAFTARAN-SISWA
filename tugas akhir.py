from tkinter import simpledialog
import mysql.connector
import tkinter as tk
from tkinter import messagebox, Toplevel, Text, Scrollbar, RIGHT, Y, END

BG_COLOR = "#f2f2f2"
LABEL_COLOR = "#333"
BUTTON_COLOR = "#4CAF50"
BUTTON_RED = "#DC143C"
BUTTON_TEXT_COLOR = "white"
FONT = ("Arial", 12)
        
def test_connection():
    try:
        conn = mysql.connector.connect(
            host="localhost",
            user="root",
            password="",
            database="penerimaan_siswa"
        )
        conn.close()
        return True
    except mysql.connector.Error:
        return False

class Password:
    def __init__(self, root):
        self.root = root
        self.__password = "kelompok 3"  # Enkapsulasi password

    def __verify_password(self, input_password):
        return input_password == self.__password

    def request_password(self):
        password_window = tk.Toplevel(self.root)
        password_window.title("Masukkan Kata Sandi")
        password_window.geometry("300x150")
        password_window.configure(bg=BG_COLOR)

        label = tk.Label(password_window, text="Masukkan Kata Sandi:", bg=BG_COLOR, fg=LABEL_COLOR, font=FONT)
        label.pack(pady=10)

        password_entry = tk.Entry(password_window, show="*", font=FONT)
        password_entry.pack(pady=5)

        def handle_submit():
            if self.__verify_password(password_entry.get()):
                password_window.destroy()
                self.execute()  
            else:
                messagebox.showerror("Error", "Kata sandi salah! Akses ditolak.")

        submit_button = tk.Button(password_window, text="Submit", command=handle_submit,
                                  bg=BUTTON_COLOR, fg=BUTTON_TEXT_COLOR, font=FONT)
        submit_button.pack(pady=5)

    def execute(self):
        id_siswa = simpledialog.askstring("Masukkan ID", "Masukkan ID Calon Mahasiswa: ")
        if not id_siswa:
            messagebox.showwarning("Peringatan", "ID tidak boleh kosong.")
            return

        if not test_connection():
            messagebox.showerror("Error", "Gagal terhubung ke database")
            return
    
def save_data():
    data = (
        entry_nama_lengkap.get().strip(),
        entry_tempat_lahir.get().strip(),
        entry_nik.get().strip(),
        entry_nisn.get().strip(),
        entry_nama_orang_tua.get().strip(),
        entry_asal_sekolah.get().strip(),
        entry_no_hp.get().strip(),
        entry_alamat.get().strip(),
        entry_jalur_pendaftaran.get().strip(),
        entry_jurusan.get().strip()
    )
    
    if any(not val for val in data):
        messagebox.showerror("Error", "Tolong isi semua kolom dengan benar")
        return

    if not test_connection():
        messagebox.showerror("Error", "Gagal terhubung ke database")
        return

    try:
        conn = mysql.connector.connect(
            host="localhost",
            user="root",
            password="",
            database="penerimaan_siswa"
        )

        cursor = conn.cursor()

        cursor.execute("CALL InsertMahasiswa(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)", data)

        id_siswa = data[3] 

        cursor.execute("CALL log_pendaftaran(%s)", (id_siswa,))

        conn.commit()
        messagebox.showinfo("Info", "Data berhasil disimpan dan dicatat di log.")
        cursor.close()
        conn.close()

    except mysql.connector.Error as err:
        messagebox.showerror("Error", f"Gagal menyimpan data: {err}")

def get_mahasiswa_view():
    if not test_connection():
        messagebox.showerror("Error", "Gagal terhubung ke database")
        return

    try:
        conn = mysql.connector.connect(
            host="localhost",
            user="root",
            password="",
            database="penerimaan_siswa"
        )
        cursor = conn.cursor()

        cursor.execute("SELECT * FROM view_data_siswa_lengkap")
        results = cursor.fetchall()
        cursor.close()
        conn.close()

        if not results:
            messagebox.showinfo("Info", "Tidak ada data siswa ditemukan.")
            return

        result_window = Toplevel()
        result_window.title("Data Siswa dari View")

        text_area = Text(result_window, wrap="none", width=180, height=25, font=("Courier New", 10))
        scrollbar = Scrollbar(result_window, command=text_area.yview)
        text_area.configure(yscrollcommand=scrollbar.set)
        scrollbar.pack(side=RIGHT, fill=Y)
        text_area.pack()

        headers = [
            "ID", "Nama", "Tempat Lahir", "NIK", "NISN",
            "Orang Tua", "Asal Sekolah", "No HP", "Alamat",
            "Jalur", "Jurusan"
        ]

        column_widths = [12, 20, 15, 18, 12, 15, 20, 14, 18, 10, 20]

        def format_row(row_data):
            return "".join(str(data).ljust(w) for data, w in zip(row_data, column_widths))

        text_area.insert(END, format_row(headers) + "\n")
        text_area.insert(END, "-" * sum(column_widths) + "\n")

        for row in results:
            text_area.insert(END, format_row(row) + "\n")

        text_area.config(state='disabled')

    except mysql.connector.Error as err:
        messagebox.showerror("Error", f"Gagal mengambil data dari view: {err}")

class Update(Password):
    def __init__(self, root):
        super().__init__(root)

    def update_data(self):
        self.request_password()

    def execute(self):
        id_siswa = simpledialog.askstring("Masukkan ID", "Masukkan ID Calon Mahasiswa yang ingin diupdate:")
        if not id_siswa:
            messagebox.showwarning("Peringatan", "ID tidak boleh kosong.")
            return

        if not test_connection():
            messagebox.showerror("Error", "Gagal terhubung ke database")
            return

        try:
            conn = mysql.connector.connect(
                host="localhost",
                user="root",
                password="",
                database="penerimaan_siswa"
            )
            cursor = conn.cursor()

            cursor.execute("""
                SELECT 
                    TCM.ID_Calon_Mahasiswa, TNS.Nama_siswa, TTL.Tempat_Lahir, TCM.NIK, TCM.NISN,
                    TCM.Orang_Tua, TCM.ID_Sekolah, TCM.No_HP, TCM.Alamat, TCM.Jalur_Pendaftaran,
                    TJS.ID_Jurusan
                FROM Tabel_Calon_Mahasiswa TCM
                JOIN Tabel_Nama_Siswa TNS ON TCM.ID_Calon_Mahasiswa = TNS.ID_Calon_Mahasiswa
                JOIN Tabel_Tempat_Lahir TTL ON TCM.ID_Calon_Mahasiswa = TTL.ID_Calon_Mahasiswa
                JOIN Tabel_Jurusan_Siswa TJS ON TCM.ID_Calon_Mahasiswa = TJS.ID_Calon_Mahasiswa
                WHERE TCM.ID_Calon_Mahasiswa = %s
            """, (id_siswa,))

            result = cursor.fetchone()
            if not result:
                messagebox.showerror("Error", f"Tidak ditemukan data dengan ID: {id_siswa}")
                cursor.close()
                conn.close()
                return

            data = (
                entry_nama_lengkap.get().strip(),
                entry_tempat_lahir.get().strip(),
                entry_nik.get().strip(),
                entry_nisn.get().strip(),
                entry_nama_orang_tua.get().strip(),
                entry_asal_sekolah.get().strip(),
                entry_no_hp.get().strip(),
                entry_alamat.get().strip(),
                entry_jalur_pendaftaran.get().strip(),
                entry_jurusan.get().strip()
            )

            if any(not val for val in data):
                messagebox.showerror("Error", "Tolong isi semua kolom dengan benar")
                return

            cursor.execute("""
                UPDATE Tabel_Calon_Mahasiswa
                SET ID_Sekolah=%s, NIK=%s, NISN=%s, No_HP=%s, Alamat=%s, Orang_Tua=%s, Jalur_Pendaftaran=%s
                WHERE ID_Calon_Mahasiswa=%s
            """, (data[5], data[2], data[3], data[6], data[7], data[4], data[8], id_siswa))

            cursor.execute("""
                UPDATE Tabel_Nama_Siswa
                SET Nama_siswa=%s
                WHERE ID_Calon_Mahasiswa=%s
            """, (data[0], id_siswa))

            cursor.execute("""
                UPDATE Tabel_Tempat_Lahir
                SET Tempat_Lahir=%s
                WHERE ID_Calon_Mahasiswa=%s
            """, (data[1], id_siswa))

            cursor.execute("""
                UPDATE Tabel_Jurusan_Siswa
                SET ID_Jurusan=%s
                WHERE ID_Calon_Mahasiswa=%s
            """, (data[9], id_siswa))

            conn.commit()
            messagebox.showinfo("Sukses", "Data berhasil diperbarui.")
            cursor.close()
            conn.close()

        except mysql.connector.Error as err:
            messagebox.showerror("Error", f"Gagal mengupdate data: {err}")

class Delete(Password):
    def __init__(self, root):
        super().__init__(root)

    def delete_data(self):
        self.request_password()

    def execute(self):
        id_siswa = simpledialog.askstring("Hapus Data", "Masukkan ID Calon Mahasiswa yang ingin dihapus:")
        if not id_siswa:
            messagebox.showwarning("Peringatan", "ID tidak boleh kosong.")
            return
        
        confirm = messagebox.askyesno("Konfirmasi", f"Apakah Anda yakin ingin menghapus data siswa dengan ID {id_siswa}?")
        if not confirm:
            return

        if not test_connection():
            messagebox.showerror("Error", "Gagal terhubung ke database")
            return

        try:
            conn = mysql.connector.connect(
                host="localhost",
                user="root",
                password="",
                database="penerimaan_siswa"
            )
            cursor = conn.cursor()
            cursor.execute("DELETE FROM Tabel_Jurusan_Siswa WHERE ID_Calon_Mahasiswa = %s", (id_siswa,))
            cursor.execute("DELETE FROM Tabel_Tempat_Lahir WHERE ID_Calon_Mahasiswa = %s", (id_siswa,))
            cursor.execute("DELETE FROM Tabel_Nama_Siswa WHERE ID_Calon_Mahasiswa = %s", (id_siswa,))
            cursor.execute("DELETE FROM Tabel_Calon_Mahasiswa WHERE ID_Calon_Mahasiswa = %s", (id_siswa,))

            conn.commit()
            cursor.close()
            conn.close()

            messagebox.showinfo("Sukses", f"Data siswa dengan ID {id_siswa} berhasil dihapus.")

        except mysql.connector.Error as err:
            messagebox.showerror("Error", f"Gagal menghapus data: {err}")

def get_log_pendaftaran():
    if not test_connection():
        messagebox.showerror("Error", "Gagal terhubung ke database")
        return

    try:
        conn = mysql.connector.connect(
            host="localhost",
            user="root",
            password="",
            database="penerimaan_siswa"
        )
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM log_pendaftaran")
        data = cursor.fetchall()

        if not data:
            messagebox.showinfo("Log Pendaftaran", "Tidak ada data pendaftaran")
            return

        result = "\n".join([f"ID: {row[1]} - Waktu: {row[2]}" for row in data])
        messagebox.showinfo("Log Pendaftaran", result)

        cursor.close()
        conn.close()

    except mysql.connector.Error as err:
        messagebox.showerror("Error", f"Gagal mengambil log pendaftaran: {err}")

def quit():
    exit()

root = tk.Tk()
root.title("Pendaftaran Mahasiswa Baru")
root.configure(bg=BG_COLOR)
root.geometry("600x700")

fields = [
    ("Nama Lengkap", "nama_lengkap"),("Tempat Lahir", "tempat_lahir"),
    ("NIK", "nik"), ("NISN", "nisn"), ("Nama Orang Tua", "nama_orang_tua"), ("Asal Sekolah", "asal_sekolah"),
    ("No HP", "no_hp"), ("Alamat", "alamat"), ("Jalur Pendaftaran", "jalur_pendaftaran"), ("Jurusan", "jurusan")
]

entries = {}

for label_text, field_name in fields:
    frame = tk.Frame(root, bg=BG_COLOR)
    frame.pack(fill="x", padx=20, pady=5)

    label = tk.Label(frame, text=label_text, bg=BG_COLOR, fg=LABEL_COLOR, font=FONT)
    label.pack(side="left", padx=10)

    entry = tk.Entry(frame, font=FONT, width=30)
    entry.pack(side="right", padx=10)
    
    entries[field_name] = entry

entry_nama_lengkap = entries["nama_lengkap"]
entry_tempat_lahir = entries["tempat_lahir"]
entry_nik = entries["nik"]
entry_nisn = entries["nisn"]
entry_nama_orang_tua = entries["nama_orang_tua"]
entry_asal_sekolah = entries["asal_sekolah"]
entry_no_hp = entries["no_hp"]
entry_alamat = entries["alamat"]
entry_jalur_pendaftaran = entries["jalur_pendaftaran"]
entry_jurusan = entries["jurusan"]

btn_frame = tk.Frame(root, bg=BG_COLOR)
btn_frame.pack(fill="x", padx=20, pady=10)


update_system = Update(root)
delete_system = Delete(root)

save_button = tk.Button(btn_frame, text="Simpan Data", command=save_data, 
                        bg=BUTTON_COLOR, fg=BUTTON_TEXT_COLOR, font=FONT, padx=50, pady=5)
save_button.pack()

view_button = tk.Button(btn_frame, text="Lihat Data Mahasiswa", command=get_mahasiswa_view, 
                        bg=BUTTON_COLOR, fg=BUTTON_TEXT_COLOR, font=FONT, padx=19, pady=5)
view_button.pack()

log_button = tk.Button(btn_frame, text="Lihat Log Pendaftaran", command=get_log_pendaftaran, 
                        bg=BUTTON_COLOR, fg=BUTTON_TEXT_COLOR, font=FONT, padx=19, pady=5)
log_button.pack()

update_button = tk.Button(btn_frame, text="Update data siswa", command=update_system.update_data, 
                        bg=BUTTON_COLOR, fg=BUTTON_TEXT_COLOR, font=FONT, padx=30, pady=5)
update_button.pack()

delete_button = tk.Button(btn_frame, text="Menghapus data siswa", command=delete_system.delete_data, 
                        bg=BUTTON_RED, fg=BUTTON_TEXT_COLOR, font=FONT, padx=25, pady=5)
delete_button.pack()

quit_button = tk.Button(btn_frame, text="Keluar program", command=quit, 
                        bg=BUTTON_RED, fg=BUTTON_TEXT_COLOR, font=FONT, padx=50, pady=10)
quit_button.pack()
root.mainloop()