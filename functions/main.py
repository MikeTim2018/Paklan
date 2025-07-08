# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

from firebase_functions import firestore_fn, scheduler_fn, https_fn
from firebase_admin import initialize_app, firestore, messaging
import json
import datetime
app = initialize_app()


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
    transactions = db.collection("transactions").where("status", "==", "En proceso")
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
                        title=f"Te quedan {time_result} para {"Aceptar" if not status_dict.get("buyerConfirmation") else "Concretar"} un Trato con {seller.get("firstName")}",
                        body=f"Estatus: {transaction_dict.get("status")}, Monto: ${transaction_dict.get("amount")} mxn.\n{status_dict.get("details")}"
                    ),
                    tokens=buyer.get("tokens"),
                    data={
                        "message": f"Tienes una nueva actualización de un Trato con {seller.get("firstName")}",
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
                    title=f"Te quedan {time_result} para {"Aceptar" if not status_dict.get("sellerConfirmation") else "Concretar"} un Trato con {buyer.get("firstName")}",
                    body=f"Estatus: {status_dict.get("status")}, Monto: ${transaction_dict.get("amount")} mxn.\n{status_dict.get("details")}"
                ),
                data={
                    "message": f"Tienes una nueva actualización de un Trato con {buyer.get("firstName")}",
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
    transactions = db.collection("transactions").where("status", "==", "En proceso")
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
                        title=f"Te quedan {time_result} para {"Aceptar" if not status_dict.get("buyerConfirmation") else "Concretar"} un Trato con {seller.get("firstName")}",
                        body=f"Estatus: {transaction_dict.get("status")}, Monto: ${transaction_dict.get("amount")} mxn.\n{status_dict.get("details")}"
                    ),
                    tokens=buyer.get("tokens"),
                    data={
                        "message": f"Tienes una nueva actualización de un Trato con {seller.get("firstName")}",
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
                    title=f"Te quedan {time_result} para {"Aceptar" if not status_dict.get("sellerConfirmation") else "Concretar"} un Trato con {buyer.get("firstName")}",
                    body=f"Estatus: {status_dict.get("status")}, Monto: ${transaction_dict.get("amount")} mxn.\n{status_dict.get("details")}"
                ),
                data={
                    "message": f"Tienes una nueva actualización de un Trato con {buyer.get("firstName")}",
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

@scheduler_fn.on_schedule(schedule="*/5 * * * *")
def update_remaining_hours(_) -> None:
    """
    updates the remaining time on the firestore database for all in progress transactions
    runs every 10 minutes, so that if a deal expired, cancels it and x number of
      times in a day user will get notified that the deal is abou to expire
    Args:
        event (scheduler_fn.ScheduledEvent): _description_
    """
    db = firestore.client()
    transactions = db.collection("transactions").where("status", "==", "En proceso")
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


@firestore_fn.on_document_created(max_instances=40, document="transactions/{transactionId}/status/{statusId}") #min_instances=5 costs $35.25 dollars monthly to keep warm in production only to fasten responses on deals
def update_transactions(event: firestore_fn.Event[firestore_fn.DocumentSnapshot | None]) -> None:
    """
    Function to update the transaction status and status date when status is created
    """
    if event.data is None:
        print("no event data is provided!")
        return
    try:
        status = event.data.get("status")
        transaction_id = event.params['transactionId']
    except KeyError:
        # No field, so do nothing.
        return
    db = firestore.client()

    transaction_document = db.collection("transactions").document(transaction_id)
    transaction = transaction_document.get().to_dict()
    buyer_doc = db.collection("users").document(transaction.get("members")["buyerId"])
    buyer = buyer_doc.get().to_dict()
    seller_doc = db.collection("users").document(transaction.get("members")["sellerId"])
    seller = seller_doc.get().to_dict()
    if buyer.get("tokens"):
        msg = messaging.send_each_for_multicast(
            multicast_message=messaging.MulticastMessage(
                notification=messaging.Notification(
                    title=f"Tienes una nueva actualización de un Trato con {seller.get("firstName")}",
                    body=f"Estatus: {status}, Monto: ${transaction.get("amount")} mxn.\n{event.data.get("details")}"
                ),
                tokens=buyer.get("tokens"),
                data={
                    "message": f"Tienes una nueva actualización de un Trato con {seller.get("firstName")}",
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
    msg2 = messaging.send_each_for_multicast(
        multicast_message=messaging.MulticastMessage(
            tokens=seller.get("tokens"),
            notification=messaging.Notification(
                title=f"Tienes una nueva actualización de un Trato con {buyer.get("firstName")}",
                body=f"Estatus: {status}, Monto: ${transaction.get("amount")} mxn.\n{event.data.get("details")}"
            ),
            data={
                "message": f"Tienes una nueva actualización de un Trato con {buyer.get("firstName")}",
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