# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

from firebase_functions import firestore_fn, scheduler_fn, https_fn
from firebase_functions.params import SecretParam
from firebase_admin import initialize_app, firestore, messaging
from firebase_functions.options import SupportedRegion
import json
import os
import datetime
import stripe
app = initialize_app()
# webhook_secret = os.environ.get("STRIPE_WEBHOOK_SECRET")
my_json_secret = SecretParam("STRIPE_SECRET_JSON")


@https_fn.on_request(secrets=[my_json_secret])
@https_fn.on_call()
def create_connect_account(req: https_fn.CallableRequest) -> dict:
    """
    Creates a Stripe Connect account. 
    Auth context is automatically available in req.auth
    """
    # 1. Automatic Authentication Check
    if req.auth is None:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.UNAUTHENTICATED,
            message="The user must be authenticated."
        )
    db = firestore.client()
    # 2. Get data directly (No JSON parsing needed)
    # req.auth.uid is safer than passing userId from client
    user_id = req.auth.uid
    email = req.data.get("email")

    if not email:
         raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
            message="The function must be called with an 'email' argument."
        )

    try:
        # 3. Check Firestore
        user_ref = db.collection("users").document(user_id)
        user_doc = user_ref.get()

        stripe_account_id = None
        if user_doc.exists:
            stripe_account_id = user_doc.to_dict().get("stripeAccountId")

        # 4. Create Account if missing
        if not stripe_account_id:
            account = stripe.Account.create(
                type="express",
                email=email,
                capabilities={
                    "card_payments": {"requested": True},
                    "transfers": {"requested": True},
                },
            )
            stripe_account_id = account.id
            user_ref.set({"stripeAccountId": stripe_account_id}, merge=True)

        # 5. Generate Link
        account_link = stripe.AccountLink.create(
                            account=stripe_account_id,
                            refresh_url="myapp://stripe-onboarding?status=refresh",
                            return_url="myapp://stripe-onboarding?status=success",
                            type="account_onboarding",
                        )

        # Return a simple dictionary (Firebase SDK handles JSON conversion)
        return {"url": account_link.url}

    except Exception as e:
        # Throw specific HTTPS errors that the Flutter client can catch
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INTERNAL,
            message=str(e)
        )


# @https_fn.on_request()
# def create_destination_payment(request):
#     """Creates a PaymentIntent split between the platform and the seller."""
#     db = firestore.client()
#     if request.method == "OPTIONS":
#         headers = {
#             "Access-Control-Allow-Origin": "*",
#             "Access-Control-Allow-Methods": "POST",
#             "Access-Control-Allow-Headers": "Content-Type",
#             "Access-Control-Max-Age": "3600",
#         }
#         return ("", 204, headers)

#     headers = {"Access-Control-Allow-Origin": "*"}

#     try:
#         request_json = request.get_json(silent=True)
#         amount = request_json.get("amount")  # In cents (e.g., 2000 = $20.00)
#         seller_id = request_json.get("sellerId")

#         # Fetch seller's Stripe ID from Firestore
#         seller_doc = db.collection("users").document(seller_id).get()
#         if not seller_doc.exists:
#             return (json.dumps({"error": "Seller document not found"}), 404, headers)

#         stripe_account_id = seller_doc.to_dict().get("stripeAccountId")
#         if not stripe_account_id:
#             return (json.dumps({"error": "Seller payout account not configured"}), 400, headers)

#         # Calculate a 10% platform application fee
#         application_fee = int(amount * 0.10)

#         # Create the Payment Intent
#         payment_intent = stripe.PaymentIntent.create(
#             amount=amount,
#             currency="usd",
#             application_fee_amount=application_fee,
#             transfer_data={
#                 "destination": stripe_account_id,
#             },
#         )

#         return (json.dumps({"clientSecret": payment_intent.client_secret}), 200, headers)

#     except Exception as e:
#         return (json.dumps({"error": str(e)}), 500, headers)


# @https_fn.on_request()
# def stripe_webhook(request):
#     """Listens for event confirmations from Stripe to update Firestore."""
#     db = firestore.client()
#     payload = request.get_data()
#     sig_header = request.headers.get("Stripe-Signature")

#     try:
#         event = stripe.Webhook.construct_event(
#             payload, sig_header, webhook_secret
#         )
#     except ValueError:
#         return ("Invalid payload", 400)
#     except stripe.error.SignatureVerificationError:
#         return ("Invalid signature", 400)

#     # Handle the account.updated event
#     if event["type"] == "account.updated":
#         account = event["data"]["object"]

#         # If onboarding is fully submitted and charges are unblocked
#         if account.get("details_submitted") and account.get("charges_enabled"):
#             stripe_id = account.get("id")

#             # Look up the matching Firestore user profile
#             users_ref = db.collection("users")
#             query = users_ref.where("stripeAccountId", "==", stripe_id).limit(1)
#             docs = query.get()

#             for doc in docs:
#                 doc.reference.update({"stripeOnboardingComplete": True})

#     return (json.dumps({"success": True}), 200)

@https_fn.on_call(max_instances=40, memory=256) #min_instances=1 $2.5 dollars month to fasten load times
def get_time_from_server(req: https_fn.CallableRequest):
    """
    Gets the datetime from firebase directly
    """
    return {"server_datetime": str(datetime.datetime.now(datetime.timezone.utc)).replace(" ", "T")}

@scheduler_fn.on_schedule(schedule="0 */6 * * *")
def send_reminder(_) -> None:
    """
    updates the remaining time on the firestore database for all in progress transactions
    runs every 10 minutes, so that if a deal expired, cancels it and x number of
      times in a day user will get notified that the deal is abou to expire
    Args:
        event (scheduler_fn.ScheduledEvent): _description_
    """
    db = firestore.client()
    transactions = db.collection("transactions").where("status", "in", ["Aceptado", "Depositado", "Enviado"])
    transactions_list = transactions.get()
    for transac in transactions_list:
        transaction_dict = transac.to_dict()
        time_rem = transaction_dict.get('timeLimit') - datetime.datetime.now(datetime.timezone.utc)
        minutes, _ = divmod(time_rem.days * 1400*60 + time_rem.seconds, 60)
        if minutes <= 0:
            continue
        if time_rem.days > 2:
            continue
        status = db.collection("transactions").document(transaction_dict.get("transactionId")).collection("status").document(
                                                                                        transaction_dict.get("statusId")
                                                                                        ).get()
        status_dict = status.to_dict()
        buyer_doc = db.collection("users").document(transaction_dict.get("members")["buyerId"])
        buyer = buyer_doc.get().to_dict()
        seller_doc = db.collection("users").document(transaction_dict.get("members")["sellerId"])
        seller = seller_doc.get().to_dict()
        time_result = f"{time_rem.days} días" if time_rem.days>0 else f"{minutes//60} horas"
        if buyer.get("tokens"):
            msg = messaging.send_each_for_multicast(
                multicast_message=messaging.MulticastMessage(
                    notification=messaging.Notification(
                        title=f"Te quedan {time_result} para {"Aceptar" if not status_dict.get("buyerConfirmation") else "Concretar"} un Trato con {seller.get("displayName")}",
                        body=f"Estatus: {transaction_dict.get("status")}, Monto: ${transaction_dict.get("amount")} mxn.\n{status_dict.get("details")}"
                    ),
                    tokens=buyer.get("tokens"),
                    data={
                        "message": f"Tienes una nueva actualización de un Trato con {seller.get("displayName")}",
                        "status": transaction_dict.get("status"),
                        "transaction": json.dumps({
                            "transactionId": transaction_dict.get("transactionId"),
                            "statusId": transaction_dict.get("statusId"),
                            "details": status_dict.get("details"),
                        })
                    },
                    android=messaging.AndroidConfig(priority='high')
                )
            )
            print(msg.failure_count)
            tokens_to_erase = []
            if msg.failure_count>0:
                for index, response in enumerate(msg.responses):
                    if response.success:
                        continue
                    print(response.exception)
                    print(response.exception.code)
                    if response.exception.code == 'NOT_FOUND':
                        tokens_to_erase.append(index)
            new_tokens = [token for ind, token in enumerate(buyer.get("tokens")) if ind not in tokens_to_erase]
            buyer_doc.update({
                "tokens": new_tokens
            })
        if not seller.get("tokens"):
            return
        msg2 = messaging.send_each_for_multicast(
            multicast_message=messaging.MulticastMessage(
                tokens=seller.get("tokens"),
                notification=messaging.Notification(
                    title=f"Te quedan {time_result} para {"Aceptar" if not status_dict.get("sellerConfirmation") else "Concretar"} un Trato con {buyer.get("displayName")}",
                    body=f"Estatus: {status_dict.get("status")}, Monto: ${transaction_dict.get("amount")} mxn.\n{status_dict.get("details")}"
                ),
                data={
                    "message": f"Tienes una nueva actualización de un Trato con {buyer.get("displayName")}",
                    "status": status_dict.get("status"),
                    "transaction": json.dumps({
                        "transactionId": transaction_dict.get("transactionId"),
                        "statusId": transaction_dict.get("statusId"),
                        "details": status_dict.get("details"),
                    })
                },
                android=messaging.AndroidConfig(priority='high')
            )
        )
        tokens_to_erase = []
        print(msg2.failure_count)
        if msg2.failure_count>0:
            for index, response in enumerate(msg2.responses):
                if response.success:
                    continue
                if response.exception.code == 'NOT_FOUND':
                    tokens_to_erase.append(index)
        new_tokens = [token for ind, token in enumerate(seller.get("tokens")) if ind not in tokens_to_erase]
        seller_doc.update({
            "tokens": new_tokens
        })

@scheduler_fn.on_schedule(schedule="0 7 */2 * *")
def send_reminder_days(_) -> None:
    """
    updates the remaining time on the firestore database for all in progress transactions
    runs every 10 minutes, so that if a deal expired, cancels it and x number of
      times in a day user will get notified that the deal is abou to expire
    Args:
        event (scheduler_fn.ScheduledEvent): _description_
    """
    db = firestore.client()
    transactions = db.collection("transactions").where("status", "in", "[Aceptado, Depositado, Enviado]")
    transactions_list = transactions.get()
    for transac in transactions_list:
        transaction_dict = transac.to_dict()
        time_rem = transaction_dict.get('timeLimit') - datetime.datetime.now(datetime.timezone.utc)
        minutes, _ = divmod(time_rem.days * 1400*60 + time_rem.seconds, 60)
        if minutes <= 0:
            continue
        if time_rem.days <= 2:
            continue
        status = db.collection("transactions").document(transaction_dict.get("transactionId")).collection("status").document(
                                                                                        transaction_dict.get("statusId")
                                                                                        ).get()
        status_dict = status.to_dict()
        buyer_doc = db.collection("users").document(transaction_dict.get("members")["buyerId"])
        buyer = buyer_doc.get().to_dict()
        seller_doc = db.collection("users").document(transaction_dict.get("members")["sellerId"])
        seller = seller_doc.get().to_dict()
        time_result = f"{time_rem.days} días" if time_rem.days>0 else f"{minutes//60} horas"
        if buyer.get("tokens"):
            msg = messaging.send_each_for_multicast(
                multicast_message=messaging.MulticastMessage(
                    notification=messaging.Notification(
                        title=f"Te quedan {time_result} para {"Aceptar" if not status_dict.get("buyerConfirmation") else "Concretar"} un Trato con {seller.get("displayName")}",
                        body=f"Estatus: {transaction_dict.get("status")}, Monto: ${transaction_dict.get("amount")} mxn.\n{status_dict.get("details")}"
                    ),
                    tokens=buyer.get("tokens"),
                    data={
                        "message": f"Tienes una nueva actualización de un Trato con {seller.get("displayName")}",
                        "status": transaction_dict.get("status"),
                        "transaction": json.dumps({
                            "transactionId": transaction_dict.get("transactionId"),
                            "statusId": transaction_dict.get("statusId"),
                            "details": status_dict.get("details"),
                        })
                    },
                    android=messaging.AndroidConfig(priority='high')
                )
            )
            print(msg.failure_count)
            tokens_to_erase = []
            if msg.failure_count>0:
                for index, response in enumerate(msg.responses):
                    if response.success:
                        continue
                    print(response.exception)
                    print(response.exception.code)
                    if response.exception.code == 'NOT_FOUND':
                        tokens_to_erase.append(index)
            new_tokens = [token for ind, token in enumerate(buyer.get("tokens")) if ind not in tokens_to_erase]
            buyer_doc.update({
                "tokens": new_tokens
            })
        if not seller.get("tokens"):
            return
        msg2 = messaging.send_each_for_multicast(
            multicast_message=messaging.MulticastMessage(
                tokens=seller.get("tokens"),
                notification=messaging.Notification(
                    title=f"Te quedan {time_result} para {"Aceptar" if not status_dict.get("sellerConfirmation") else "Concretar"} un Trato con {buyer.get("displayName")}",
                    body=f"Estatus: {status_dict.get("status")}, Monto: ${transaction_dict.get("amount")} mxn.\n{status_dict.get("details")}"
                ),
                data={
                    "message": f"Tienes una nueva actualización de un Trato con {buyer.get("displayName")}",
                    "status": status_dict.get("status"),
                    "transaction": json.dumps({
                        "transactionId": transaction_dict.get("transactionId"),
                        "statusId": transaction_dict.get("statusId"),
                        "details": status_dict.get("details"),
                    })
                },
                android=messaging.AndroidConfig(priority='high')
            )
        )
        tokens_to_erase = []
        print(msg2.failure_count)
        if msg2.failure_count>0:
            for index, response in enumerate(msg2.responses):
                if response.success:
                    continue
                if response.exception.code == 'NOT_FOUND':
                    tokens_to_erase.append(index)
        new_tokens = [token for ind, token in enumerate(seller.get("tokens")) if ind not in tokens_to_erase]
        seller_doc.update({
            "tokens": new_tokens
        })

@scheduler_fn.on_schedule(schedule="* * */1 * *")
def update_remaining_hours(_) -> None:
    """
    updates the remaining time on the firestore database for all in progress transactions
    runs every 10 minutes, so that if a deal expired, cancels it and x number of
      times in a day user will get notified that the deal is abou to expire
    Args:
        event (scheduler_fn.ScheduledEvent): _description_
    """
    db = firestore.client()
    transactions = db.collection("transactions").where("status", "in", ["Aceptado", "Depositado", "Enviado"])
    transactions_list = transactions.get()
    for transac in transactions_list:
        transaction_dict = transac.to_dict()
        time_rem = transaction_dict.get('timeLimit') - datetime.datetime.now(datetime.timezone.utc)
        minutes, _ = divmod(time_rem.days * 86400 + time_rem.seconds, 60)
        if minutes <= 0:
            status = db.collection("transactions").document(transaction_dict.get("transactionId")).collection("status").document(
                                                                                        transaction_dict.get("statusId")
                                                                                        ).get()
            status_dict = status.to_dict()
            cancelled_date = datetime.datetime.now(datetime.timezone.utc)
            _, new_status = db.collection("transactions").document(transaction_dict.get("transactionId")).collection("status").add(
                {
                 "transactionId": transaction_dict.get("transactionId"),
                 "buyerConfirmation": status_dict.get("buyerConfirmation"),
                 "sellerConfirmation": status_dict.get("sellerConfirmation"),
                 "details": "Trato Cancelado Por Paklan. ¡Se agotó el tiempo!",
                 "status": "Cancelado",
                 "sellerId": status_dict.get("sellerId"),
                 "buyerId": status_dict.get("buyerId"),
                 "cancelled": True,
                 "reimbursementDone": status_dict.get("reimbursementDone"),
                 "paymentDone": status_dict.get("paymentDone"),
                 "paymentTransferred": status_dict.get("paymentTransferred"),
                 "creationDate": cancelled_date
               }
            )
            db.collection("transactions").document(transaction_dict.get("transactionId")).update(
                {
                    "updatedDate": cancelled_date,
                    "status": "Cancelado",
                    "statusId": new_status.id,
                }
            )
            new_status.update(
                {
                    "statusId": new_status.id
                }
            )


@firestore_fn.on_document_created(max_instances=40, document="chats/{chatId}/messages/{messageId}", region=SupportedRegion.US_CENTRAL1) #min_instances=5 costs $35.25 dollars monthly to keep warm in production only to fasten responses on deals
def send_message_notifications(event: firestore_fn.Event[firestore_fn.DocumentSnapshot | None]) -> None:
    """
    Function to update the transaction status and status date when status is created
    """
    if event.data is None:
        print("no event data is provided!")
        return
    try:
        print("retrieving data from event")
        chat_id = event.params['chatId']
        sender_id = event.data.get("senderId")
        sender_name = event.data.get("senderName")
        message_text = event.data.get('message')
    except KeyError as ky:
        print(f"an error in event data occurred {ky}")
        return
    db = firestore.client()
    # --- 1. IDEMPOTENCY & TRANSACTION LOCKING HANDLING ---
    chat = db.collection("chats").document(chat_id)
    chat_snapshot = chat.get().to_dict() if chat.exists else {}
    chat_members = chat_snapshot.get("members", {})
    chat_members_filtered = [member for member in chat_members if member != sender_id]
    users = []
    for member_id in chat_members_filtered:
        user_doc = db.collection("users").document(member_id).get()
        if user_doc.exists:
            user_dict = user_doc.to_dict()
            users.append(user_dict['tokens'])
    print("sending multicast message to buyer")
    title = f"Nuevo mensaje de {sender_name} en el chat"
    body = f"{message_text}"
    msg = messaging.send_each_for_multicast(
        multicast_message=messaging.MulticastMessage(
            notification=messaging.Notification(
                title=title,
                body=body
            ),
            tokens=users,
            data={
                "title": title,
                "message": message_text
            },
            android=messaging.AndroidConfig(priority='high')
        )
    )



@firestore_fn.on_document_created(max_instances=40, document="transactions/{transactionId}/status/{statusId}") #min_instances=5 costs $35.25 dollars monthly to keep warm in production only to fasten responses on deals
def update_transactions(event: firestore_fn.Event[firestore_fn.DocumentSnapshot | None]) -> None:
    """
    Function to update the transaction status and status date when status is created
    """
    if event.data is None:
        print("no event data is provided!")
        return
    try:
        print("retrieving data from event")
        status = event.data.get("status")
        transaction_id = event.params['transactionId']
        status_id = event.params['statusId']
        buyer_confirmation = event.data.get("buyerConfirmation")
        seller_confirmation = event.data.get("sellerConfirmation")
        
        # Safely extract optional ratings
        buyer_rating = event.data.get("buyerRating")
        seller_rating = event.data.get("sellerRating")
        seller_rating_message = event.data.get("completedRatingMessageForSeller", [])
        buyer_rating_message = event.data.get("completedRatingMessageForBuyer", [])
        
        previous_state_id = event.data.get("previousStateId") if "previousStateId" in event.data.to_dict() else None
    except KeyError as ky:
        print(f"an error in event data occurred {ky}")
        return

    print("finished validating the event data")
    db = firestore.client()
    # --- 1. IDEMPOTENCY & TRANSACTION LOCKING HANDLING ---
    transaction_document = db.collection("transactions").document(transaction_id)
    
    # Using an atomic transaction block to handle state updates and mathematical increments safely
    @firestore.transactional
    def update_in_transaction(transaction_db, tx_ref, status_ref):
        tx_snapshot = tx_ref.get(transaction_db)
        tx_data = tx_snapshot.to_dict() if tx_snapshot.exists else {}
        
        # Verify if this specific status update was already calculated (Idempotency check)
        processed_ratings = tx_data.get("processedRatings", {})
        if processed_ratings.get(status_id):
            print(f"Status {status_id} already processed. Skipping aggregation.")
            return tx_data, False
            
        # Update root transaction metrics using native Firestore timestamps
        server_timestamp = firestore.SERVER_TIMESTAMP
        updates = {"updatedDate": server_timestamp}
        
        if not tx_data.get('creationDate'):
            updates["creationDate"] = server_timestamp
            updates["timeLimit"] = datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(days=1)
            
        if status == "Aceptado" and 'Trato aceptado' in tx_data.get("details", ""):
            updates["creationDate"] = server_timestamp
            updates["timeLimit"] = datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(days=10)
            
        transaction_db.update(tx_ref, updates)
        
        # Update the nested status doc timestamps
        transaction_db.update(status_ref, {
            "creationDate": server_timestamp,
            "updatedDate": server_timestamp
        })
        
        # --- 2. MULTI-ROLE SCORE AGGREGATION ---
        members = tx_data.get("members", {})
        
        # Aggregate Seller Stats
        if seller_rating is not None and "sellerId" in members:
            seller_id = members["sellerId"]
            seller_ref = db.collection("sellers").document(seller_id)
            seller_snap = seller_ref.get(transaction_db)
            
            s_data = seller_snap.to_dict() if seller_snap.exists else {}
            current_sum = s_data.get("totalRatingSum", 0)
            current_count = s_data.get("ratingCount", 0)
            
            new_sum = current_sum + int(seller_rating)
            new_count = current_count + 1
            new_average = round(new_sum / new_count, 2)
            
            # Using set with merge=True lets this work seamlessly if the collection/doc is missing
            transaction_db.set(seller_ref, {
                "totalRatingSum": firestore.Increment(int(seller_rating)),
                "ratingCount": firestore.Increment(1),
                "averageRating": new_average,
                "lastRatingMessage": ', '.join(seller_rating_message),
                "updatedDate": server_timestamp,
                "transactionId": transaction_id
            }, merge=True)
            
        # Aggregate Buyer Stats
        if buyer_rating is not None and "buyerId" in members:
            buyer_id = members["buyerId"]
            buyer_ref = db.collection("buyers").document(buyer_id)
            buyer_snap = buyer_ref.get(transaction_db)
            
            b_data = buyer_snap.to_dict() if buyer_snap.exists else {}
            current_sum = b_data.get("totalRatingSum", 0)
            current_count = b_data.get("ratingCount", 0)
            
            new_sum = current_sum + int(buyer_rating)
            new_count = current_count + 1
            new_average = round(new_sum / new_count, 2)
            
            transaction_db.set(buyer_ref, {
                "totalRatingSum": firestore.Increment(int(buyer_rating)),
                "ratingCount": firestore.Increment(1),
                "averageRating": new_average,
                "lastRatingMessage": ', '.join(buyer_rating_message),
                "updatedDate": server_timestamp,
                "transactionId": transaction_id
            }, merge=True)
            
        # Flag this status_id as processed inside the transaction parent to guarantee idempotency
        transaction_db.update(tx_ref, {
            f"processedRatings.{status_id}": True
        })
        
        return tx_data, True

    # Execute our database operation safely
    status_document = transaction_document.collection("status").document(status_id)
    transaction, is_new_execution = update_in_transaction(db.transaction(), transaction_document, status_document)
    
    # If this execution is a duplicate, stop right here before sending double notifications
    if not is_new_execution:
        return
    print("validating previous state id")
    previous_state = {}
    if previous_state_id and status == 'Aceptado':
        print("previous id found!")
        previous_state = db.collection("transactions").document(transaction_id).collection("status").document(previous_state_id).get().to_dict()
    buyer_doc = db.collection("users").document(transaction.get("members")["buyerId"])
    buyer = buyer_doc.get().to_dict()
    seller_doc = db.collection("users").document(transaction.get("members")["sellerId"])
    seller = seller_doc.get().to_dict()
    print(f"building the response for each step of the process {status}")
    title_buyer = ""
    title_seller = ""
    body_buyer = ""
    body_seller = ""
    if status == 'Enviado' and not buyer_confirmation:
        title_buyer = "🚨 ¡Nueva propuesta esperándote!"
        body_buyer = f"{seller.get("displayName")} quiere hacer trato contigo. Revisa los detalles y decide si aceptarla o no."
        title_seller = "✅ ¡Listo! Tu oferta fue enviada"
        body_seller = f"Tu propuesta ya está en manos de {buyer.get("displayName")}. Espera su respuesta."
    if status == "Enviado" and not seller_confirmation:
        title_buyer = "✅ ¡Listo! Tu oferta fue enviada"
        body_buyer = f"Tu propuesta ya está en manos de {seller.get("displayName")}. Espera su respuesta."
        title_seller = "🚨 ¡Nueva propuesta esperándote!"
        body_seller = f"{buyer.get("displayName")} quiere hacer trato contigo. Revisa los detalles y decide si aceptarla o no."
    if status == 'Aceptado':
        print("validating previous state...")
        print(previous_state.get("buyerConfirmation"))
        if previous_state.get("buyerConfirmation"):
            title_buyer = f"🎉 ¡{seller.get("displayName")} aceptó tu propuesta!"
            body_buyer = "Recuerda que tienen 8 días para completar su trato"
            title_seller = "✅ ¡Aceptaste la propuesta!"
            body_seller = f"Ahora tienes un trato con {buyer.get('displayName')}. Espera el siguiente paso."
            
        if previous_state.get("sellerConfirmation"):
            title_seller = f"🎉 ¡{buyer.get("displayName")} aceptó tu propuesta!"
            body_seller = "Recuerda que tienen 8 días para completar su trato"
            title_buyer = "✅ ¡Aceptaste la propuesta!"
            body_buyer = f"Ahora tienes un trato con {seller.get('displayName')}. Espera el siguiente paso."
    if status == 'Depositado':
        title_seller = f'💰 {buyer.get("displayName")} realizó el pago'
        title_buyer = '✅ Pago exitoso'
        body_buyer = f'Se realizó el pago, ahora solo queda liberar los fondos a {seller.get("displayName")} para finalizar el trato'
        body_seller = f'{buyer.get("displayName")} realizó el pago, espera a que libere los fondos para cerrar el trato.'
    if status == 'Completado':
        title_seller = '🤝¡Trato finalizado con éxito!'
        title_buyer = '🤝¡Trato finalizado con éxito!'
        body_buyer = f'Marcaste el trato con {seller.get("displayName")} como completado. ¡Gracias por formar parte!'
        body_seller = f'Marcaste el trato con {buyer.get("displayName")} como completado. ¡Gracias por formar parte!'
    if status == 'Cancelado':
        title_seller = '🚫 El trato ha sido cancelado'
        title_buyer = '🚫 El trato ha sido cancelado'
        body_buyer = f'El trato con {seller.get("displayName")} ha sido cancelado.'
        body_seller = f'El trato con {buyer.get("displayName")} ha sido cancelado.'
    if buyer.get("tokens"):
        print("sending multicast message to buyer")
        msg = messaging.send_each_for_multicast(
            multicast_message=messaging.MulticastMessage(
                notification=messaging.Notification(
                    title=title_buyer,
                    body=body_buyer
                ),
                tokens=buyer.get("tokens"),
                data={
                    "message": title_buyer,
                    "status": status,
                    "transaction": json.dumps({
                        "transactionId": transaction.get("transactionId"),
                        "statusId": transaction.get("statusId"),
                        "details": event.data.get("details"),
                    })
                },
                android=messaging.AndroidConfig(priority='high')
            )
        )
        print(msg.failure_count)
        tokens_to_erase = []
        if msg.failure_count>0:
            for index, response in enumerate(msg.responses):
                if response.success:
                    continue
                print(response.exception)
                print(response.exception.code)
                if response.exception.code == 'NOT_FOUND':
                    tokens_to_erase.append(index)
        new_tokens = [token for ind, token in enumerate(buyer.get("tokens")) if ind not in tokens_to_erase]
        buyer_doc.update({
            "tokens": new_tokens
        })
    if not seller.get("tokens"):
        return
    print("sending multicast message to seller")
    msg2 = messaging.send_each_for_multicast(
        multicast_message=messaging.MulticastMessage(
            tokens=seller.get("tokens"),
            notification=messaging.Notification(
                title=title_seller,
                body=body_seller
            ),
            data={
                "message": title_seller,
                "status": status,
                "transaction": json.dumps({
                    "transactionId": transaction.get("transactionId"),
                    "statusId": transaction.get("statusId"),
                    "details": event.data.get("details"),
                })
            },
            android=messaging.AndroidConfig(priority='high')
        )
    )
    tokens_to_erase = []
    print(msg2.failure_count)
    if msg2.failure_count>0:
        for index, response in enumerate(msg2.responses):
            if response.success:
                continue
            if response.exception.code == 'NOT_FOUND':
                tokens_to_erase.append(index)
    new_tokens = [token for ind, token in enumerate(seller.get("tokens")) if ind not in tokens_to_erase]
    seller_doc.update({
        "tokens": new_tokens
    })