from django.db import connections
from django.contrib.auth.hashers import check_password
from django.core.exceptions import ValidationError
import logging

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
                
                logger.info(f"Authenticated admin: {email}")
                return admin_id
                
        except Exception as e:
            logger.error(f"Authentication error: {str(e)}")
            raise ValidationError("Authentication service unavailable")