# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

from firebase_functions import firestore_fn
from firebase_admin import initialize_app, firestore, messaging
import json
app = initialize_app()

@firestore_fn.on_document_created(document="transactions/{transactionId}/status/{statusId}")
def update_transactions(event: firestore_fn.Event[firestore_fn.DocumentSnapshot | None]) -> None:
    """
    Function to update the transaction status and status date when status is created
    """
    if event.data is None:
        return
    try:
        created_date = event.data.get("creationDate")
        status = event.data.get("status")
        transaction_id = event.params['transactionId']
        status_id = event.params['statusId']
    except KeyError:
        # No field, so do nothing.
        return
    db = firestore.client()

    transaction_document = db.collection("transactions").document(transaction_id)
    transaction_document.update(
        {
            "updatedDate": created_date,
            "status": status,
            "statusId": status_id,
            "transactionId": transaction_id
    }
    )
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
                    body=f"Estatus: {status}, Monto: {transaction.get("amount")}"
                ),
                tokens=buyer.get("tokens"),
                data={
                    "message": f"Tienes una nueva actualización de un Trato con {seller.get("firstName")}",
                    "status": status,
                    "transaction": json.dumps({
                        "transactionId": transaction.get("transactionId"),
                        "statusId": transaction.get("statusId"),
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
                body=f"Estatus: {status}, Monto: {transaction.get("amount")}"
            ),
            data={
                "message": f"Tienes una nueva actualización de un Trato con {buyer.get("firstName")}",
                "status": status,
                "transaction": json.dumps({
                    "transactionId": transaction.get("transactionId"),
                    "statusId": transaction.get("statusId"),
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