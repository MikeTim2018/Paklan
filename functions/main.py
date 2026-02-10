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


@firestore_fn.on_document_created(max_instances=40, document="transactions/{transactionId}/status/{statusId}") #min_instances=5 costs $35.25 dollars monthly to keep warm in production only to fasten responses on deals
def update_transactions(event: firestore_fn.Event[firestore_fn.DocumentSnapshot | None]) -> None:
    """
    Function to update the transaction status and status date when status is created
    """
    print("entered the function")
    if event.data is None:
        print("no event data is provided!")
        return
    try:
        print("retrieving data from event")
        status = event.data.get("status")
        transaction_id = event.params['transactionId']
        buyer_confirmation = event.data.get("buyerConfirmation")
        seller_confirmation = event.data.get("sellerConfirmation")
        if "previousStateId" in event.data.to_dict().keys():
            previous_state_id = event.data.get("previousStateId")
        else:
            previous_state_id = None
    except KeyError as ky:
        print(f"an error in event data occurred {ky}")
        # No field, so do nothing.
        return
    print("finished validating the event data")
    db = firestore.client()
    print("retrieving the transaction")
    transaction_document = db.collection("transactions").document(transaction_id)
    transaction = transaction_document.get().to_dict()
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
        body_buyer = f"{seller.get("firstName")} quiere hacer trato contigo. Revisa los detalles y decide si aceptarla o no."
        title_seller = "✅ ¡Listo! Tu oferta fue enviada"
        body_seller = f"Tu propuesta ya está en manos de {buyer.get("firstName")}. Espera su respuesta."
    if status == "Enviado" and not seller_confirmation:
        title_buyer = "✅ ¡Listo! Tu oferta fue enviada"
        body_buyer = f"Tu propuesta ya está en manos de {seller.get("firstName")}. Espera su respuesta."
        title_seller = "🚨 ¡Nueva propuesta esperándote!"
        body_seller = f"{buyer.get("firstName")} quiere hacer trato contigo. Revisa los detalles y decide si aceptarla o no."
    if status == 'Aceptado':
        print("validating previous state...")
        print(previous_state.get("buyerConfirmation"))
        if previous_state.get("buyerConfirmation"):
            title_buyer = f"🎉 ¡{seller.get("firstName")} aceptó tu propuesta!"
            body_buyer = "Recuerda que tienen 8 días para completar su trato"
            title_seller = "✅ ¡Aceptaste la propuesta!"
            body_seller = f"Ahora tienes un trato con {buyer.get('firstName')}. Espera el siguiente paso."
            
        if previous_state.get("sellerConfirmation"):
            title_seller = f"🎉 ¡{buyer.get("firstName")} aceptó tu propuesta!"
            body_seller = "Recuerda que tienen 8 días para completar su trato"
            title_buyer = "✅ ¡Aceptaste la propuesta!"
            body_buyer = f"Ahora tienes un trato con {seller.get('firstName')}. Espera el siguiente paso."
    if status == 'Depositado':
        title_seller = f'💰 {buyer.get("firstName")} realizó el pago'
        title_buyer = '✅ Pago exitoso'
        body_buyer = f'Se realizó el pago, ahora solo queda liberar los fondos a {seller.get("firstName")} para finalizar el trato'
        body_seller = f'{buyer.get("firstName")} realizó el pago, espera a que libere los fondos para cerrar el trato.'
    if status == 'Completado':
        title_seller = '🤝¡Trato finalizado con éxito!'
        title_buyer = '🤝¡Trato finalizado con éxito!'
        body_buyer = f'Marcaste el trato con {seller.get("firstName")} como completado. ¡Gracias por formar parte!'
        body_seller = f'Marcaste el trato con {buyer.get("firstName")} como completado. ¡Gracias por formar parte!'
    if status == 'Cancelado':
        title_seller = '🚫 El trato ha sido cancelado'
        title_buyer = '🚫 El trato ha sido cancelado'
        body_buyer = f'El trato con {seller.get("firstName")} ha sido cancelado.'
        body_seller = f'El trato con {buyer.get("firstName")} ha sido cancelado.'
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