from django.db import connections
from django.contrib.auth.hashers import check_password, make_password
from django.core.exceptions import ValidationError
import logging
import random
import string
from datetime import datetime, timedelta
from django.utils import timezone
import pytz

logger = logging.getLogger(__name__)


class HabitroAdminManager:
    @staticmethod
    def authenticate(email, password):
        """
        Verify email/password against admin_details table
        Returns admin_id if valid, None otherwise
        """
        try:
            with connections['habitro'].cursor() as cursor:
                # Get id, email, password, is_active
                cursor.execute(
                    """
                    SELECT id, email, password, is_active 
                    FROM admin_details 
                    WHERE email = %s
                    """,
                    [email.lower().strip()]
                )
                result = cursor.fetchone()

                if not result:
                    logger.warning(f"Admin not found: {email}")
                    return None

                admin_id, stored_email, stored_hash, is_active = result

                # Check account active status
                if not is_active:
                    logger.warning(f"Inactive admin account: {email}")
                    raise ValidationError("Account is inactive")

                # Auto-hashes and compares passwords
                if not check_password(password, stored_hash):
                    logger.warning(f"Password mismatch for: {email}")
                    return None

                # Update last_login to Sri Lanka time
                srilanka_tz = pytz.timezone('Asia/Colombo')
                now_colombo = timezone.now().astimezone(srilanka_tz)
                with connections['habitro'].cursor() as update_cursor:
                    update_cursor.execute(
                        "UPDATE admin_details SET last_login = %s WHERE id = %s",
                        [now_colombo.strftime('%Y-%m-%d %H:%M:%S'), admin_id]
                    )

                logger.info(f"Authenticated admin: {email}")
                return admin_id

        except Exception as e:
            logger.error(f"Authentication error: {str(e)}", exc_info=True)
            raise ValidationError("Authentication service unavailable")

    @staticmethod
    def generate_otp(request, email):
        """Generate and store a 6-digit OTP for password reset"""
        try:
            email = email.lower().strip()
            otp = ''.join(random.choices(string.digits, k=6))
            expiry_time = timezone.now() + timedelta(minutes=10)

            with connections['habitro'].cursor() as cursor:
                cursor.execute(
                    "SELECT id FROM admin_details WHERE email = %s",
                    [email]
                )
                if not cursor.fetchone():
                    logger.warning(f"Email not found in database: {email}")
                    return None

            # Store in session
            request.session['reset_otp'] = otp
            request.session['reset_email'] = email
            request.session['reset_otp_expiry'] = expiry_time.isoformat()
            request.session.save()

            logger.info(f"OTP generated for {email}: {otp}")
            return otp

        except Exception as e:
            logger.error(f"OTP generation error: {str(e)}", exc_info=True)
            return None

    @staticmethod
    def verify_otp(request, otp):
        """Verify if OTP is valid and not expired"""
        try:
            stored_otp = request.session.get('reset_otp')
            expiry_str = request.session.get('reset_otp_expiry')

            if not stored_otp or not expiry_str:
                logger.warning("No OTP found in session")
                return False

            expiry_time = datetime.fromisoformat(expiry_str)
            if timezone.now() > expiry_time:
                logger.warning("OTP expired")
                return False

            if str(stored_otp) == str(otp):
                logger.info("OTP verified successfully")
                return True

            logger.warning("OTP mismatch")
            return False

        except Exception as e:
            logger.error(f"OTP verification error: {str(e)}", exc_info=True)
            return False

    @staticmethod
    def reset_password(request, new_password):
        """Reset password using session email"""
        try:
            email = request.session.get('reset_email')
            if not email:
                logger.error("No email found in session for password reset")
                return False

            hashed_password = make_password(new_password)
            with connections['habitro'].cursor() as cursor:
                affected = cursor.execute(
                    """
                    UPDATE admin_details 
                    SET password = %s
                    WHERE email = %s
                    """,
                    [hashed_password, email]
                )

                if affected == 0:
                    logger.warning(f"No rows updated for {email}")
                    return False

                # Clear session data
                request.session.pop('reset_otp', None)
                request.session.pop('reset_email', None)
                request.session.pop('reset_otp_expiry', None)
                request.session.save()

                logger.info(f"Password reset successful for {email}")
                return True

        except Exception as e:
            logger.error(f"Password reset error: {str(e)}", exc_info=True)
            return False
