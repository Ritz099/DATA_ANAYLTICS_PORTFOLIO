import qrcode
from io import BytesIO

# Define your contact information in vCard format
contact_info = """BEGIN:VCARD
VERSION:3.0
FN:Ruturaj
ORG:Chaos PVT
TEL:+888888888
EMAIL:Chaos.control@gmail.com
END:VCARD
"""

# Create a QR code instance
qr = qrcode.QRCode(
    version=1,
    error_correction=qrcode.constants.ERROR_CORRECT_L,
    box_size=10,
    border=4,
)

# Add the contact information to the QR code
qr.add_data(contact_info)
qr.make(fit=True)

# Create an image from the QR code data
img = qr.make_image(fill_color="black", back_color="white")

# Save the QR code image to a file
img.save("contact_qr.png")

# Display the QR code image (optional)
img.show()
