# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

from firebase_functions import firestore_fn
from firebase_admin import initialize_app, firestore
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
