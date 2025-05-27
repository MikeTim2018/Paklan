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
            "statusId": status_id
    }
    )
    transaction = transaction_document.get().to_dict()
    buyer = db.collection("users").document(transaction.get("members")["buyerId"]).get().to_dict()
    seller = db.collection("users").document(transaction.get("members")["sellerId"]).get().to_dict()
    print(buyer.get("tokens"))
    if not buyer.get("tokens"):
        return
    msg = messaging.send_each_for_multicast(
        multicast_message=messaging.MulticastMessage(
            notification=messaging.Notification(
                title=f"Tienes una nueva actualización de un Trato con {seller.get("firstName")}",
                body=f"Estatus: {status}, Monto: {transaction.get("amount")}"
            ),
            tokens=buyer.get("tokens"),
            data={
                "message": f"Tienes una nueva actualización de un Trato con {seller.get("firstName")}",
                "status": status
            },
            android=messaging.AndroidConfig(priority='high')
        )
    )
    print(msg.failure_count)
    print(msg.responses)
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
            },
            android=messaging.AndroidConfig(priority='high')
        )
    )
    print(msg2.failure_count)
    print(msg2.responses)