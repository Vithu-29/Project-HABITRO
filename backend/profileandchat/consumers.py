import json
from channels.generic.websocket import AsyncWebsocketConsumer
from django.contrib.auth import get_user_model
from .models import Message
from asgiref.sync import sync_to_async

User = get_user_model()

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.room_name = self.scope['url_route']['kwargs']['room_name']
        self.room_group_name = f'chat_{self.room_name}'

        await self.channel_layer.group_add(self.room_group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(self.room_group_name, self.channel_name)

    async def receive(self, text_data):
        data = json.loads(text_data)
        message_text = data['message']
        sender_id = data['sender_id']
        receiver_id = data['receiver_id']

        # Save encrypted message to DB
        sender = await sync_to_async(User.objects.get)(id=sender_id)
        receiver = await sync_to_async(User.objects.get)(id=receiver_id)
        
        # Create message instance
        message = Message(sender=sender, receiver=receiver)
        message.set_text(message_text)  # This will encrypt the text
        await sync_to_async(message.save)()

        # Mark previous messages as read by receiver
        await self.mark_messages_as_read(sender_id, receiver_id)

        # Broadcast to room
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'chat_message',
                'message': message_text,  # Send plain text to connected clients
                'sender_id': sender_id,
                'receiver_id': receiver_id,
                'timestamp': message.timestamp.isoformat(),
                'message_id': message.id,
            }
        )

    async def mark_messages_as_read(self, sender_id, receiver_id):
        """Mark messages from sender to receiver as read"""
        def mark_read():
            Message.objects.filter(
                sender_id=sender_id,
                receiver_id=receiver_id,
                is_read=False
            ).update(is_read=True)
        
        await sync_to_async(mark_read)()

    async def chat_message(self, event):
        await self.send(text_data=json.dumps({
            'message': event['message'],
            'sender_id': event['sender_id'],
            'receiver_id': event['receiver_id'],
            'timestamp': event['timestamp'],
            'message_id': event.get('message_id'),
            'is_read': event.get('is_read', False)
        }))