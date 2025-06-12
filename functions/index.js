const functions = require("firebase-functions")
const admin = require("firebase-admin")
const stripe = require("stripe")(functions.config().stripe.secret_key)

admin.initializeApp()

// Create payment intent
exports.createPaymentIntent = functions.https.onCall(async (data, context) => {
  try {
    const { amount, currency, invoice_id, invoice_number, customer_name, customer_email, metadata } = data

    // Create payment intent with Stripe
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount,
      currency: currency,
      metadata: {
        invoice_id: invoice_id,
        invoice_number: invoice_number,
        customer_name: customer_name,
        ...metadata,
      },
      receipt_email: customer_email,
    })

    // Save payment intent to Firestore
    await admin.firestore().collection("payment_intents").doc(paymentIntent.id).set({
      id: paymentIntent.id,
      amount: amount,
      currency: currency,
      status: paymentIntent.status,
      invoice_id: invoice_id,
      invoice_number: invoice_number,
      customer_name: customer_name,
      customer_email: customer_email,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    })

    return {
      id: paymentIntent.id,
      client_secret: paymentIntent.client_secret,
      amount: paymentIntent.amount,
      currency: paymentIntent.currency,
      status: paymentIntent.status,
    }
  } catch (error) {
    console.error("Error creating payment intent:", error)
    throw new functions.https.HttpsError("internal", "Failed to create payment intent")
  }
})

// Create customer
exports.createCustomer = functions.https.onCall(async (data, context) => {
  try {
    const { name, email, phone, metadata } = data

    const customer = await stripe.customers.create({
      name: name,
      email: email,
      phone: phone,
      metadata: metadata,
    })

    // Save customer to Firestore
    await admin.firestore().collection("customers").doc(customer.id).set({
      id: customer.id,
      name: customer.name,
      email: customer.email,
      phone: customer.phone,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    })

    return {
      id: customer.id,
      name: customer.name,
      email: customer.email,
      phone: customer.phone,
      created: customer.created,
    }
  } catch (error) {
    console.error("Error creating customer:", error)
    throw new functions.https.HttpsError("internal", "Failed to create customer")
  }
})

// Send invoice
exports.sendInvoice = functions.https.onCall(async (data, context) => {
  try {
    const { customer_id, invoice_data, line_items } = data

    // Create invoice items
    const invoiceItems = []
    for (const item of line_items) {
      const invoiceItem = await stripe.invoiceItems.create({
        customer: customer_id,
        description: item.description,
        quantity: item.quantity,
        unit_amount: item.unit_amount,
      })
      invoiceItems.push(invoiceItem)
    }

    // Create invoice
    const invoice = await stripe.invoices.create({
      customer: customer_id,
      description: invoice_data.description,
      metadata: invoice_data.metadata,
      due_date: invoice_data.due_date,
    })

    // Finalize and send invoice
    await stripe.invoices.finalizeInvoice(invoice.id)
    await stripe.invoices.sendInvoice(invoice.id)

    // Save invoice to Firestore
    await admin.firestore().collection("stripe_invoices").doc(invoice.id).set({
      id: invoice.id,
      number: invoice.number,
      status: invoice.status,
      amount_due: invoice.amount_due,
      amount_paid: invoice.amount_paid,
      currency: invoice.currency,
      customer_id: customer_id,
      hosted_invoice_url: invoice.hosted_invoice_url,
      invoice_pdf: invoice.invoice_pdf,
      due_date: invoice.due_date,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    })

    return {
      id: invoice.id,
      number: invoice.number,
      status: invoice.status,
      amount_due: invoice.amount_due,
      amount_paid: invoice.amount_paid,
      currency: invoice.currency,
      customer: invoice.customer,
      hosted_invoice_url: invoice.hosted_invoice_url,
      invoice_pdf: invoice.invoice_pdf,
      due_date: invoice.due_date,
      created: invoice.created,
    }
  } catch (error) {
    console.error("Error sending invoice:", error)
    throw new functions.https.HttpsError("internal", "Failed to send invoice")
  }
})

// Get payment status
exports.getPaymentStatus = functions.https.onCall(async (data, context) => {
  try {
    const { payment_intent_id } = data

    const paymentIntent = await stripe.paymentIntents.retrieve(payment_intent_id)

    return {
      status: paymentIntent.status,
      amount: paymentIntent.amount,
      currency: paymentIntent.currency,
    }
  } catch (error) {
    console.error("Error getting payment status:", error)
    throw new functions.https.HttpsError("internal", "Failed to get payment status")
  }
})

// Refund payment
exports.refundPayment = functions.https.onCall(async (data, context) => {
  try {
    const { payment_intent_id, amount, reason } = data

    const refund = await stripe.refunds.create({
      payment_intent: payment_intent_id,
      amount: amount,
      reason: reason,
    })

    // Save refund to Firestore
    await admin.firestore().collection("refunds").doc(refund.id).set({
      id: refund.id,
      amount: refund.amount,
      currency: refund.currency,
      payment_intent_id: payment_intent_id,
      status: refund.status,
      reason: refund.reason,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    })

    return {
      id: refund.id,
      amount: refund.amount,
      currency: refund.currency,
      status: refund.status,
      reason: refund.reason,
      created: refund.created,
    }
  } catch (error) {
    console.error("Error processing refund:", error)
    throw new functions.https.HttpsError("internal", "Failed to process refund")
  }
})

// Webhook handler for Stripe events
exports.stripeWebhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers["stripe-signature"]
  const endpointSecret = functions.config().stripe.webhook_secret

  let event

  try {
    event = stripe.webhooks.constructEvent(req.body, sig, endpointSecret)
  } catch (err) {
    console.error("Webhook signature verification failed:", err.message)
    return res.status(400).send(`Webhook Error: ${err.message}`)
  }

  // Handle the event
  switch (event.type) {
    case "payment_intent.succeeded":
      const paymentIntent = event.data.object
      await handlePaymentSuccess(paymentIntent)
      break

    case "payment_intent.payment_failed":
      const failedPayment = event.data.object
      await handlePaymentFailure(failedPayment)
      break

    case "invoice.payment_succeeded":
      const paidInvoice = event.data.object
      await handleInvoicePaymentSuccess(paidInvoice)
      break

    case "invoice.payment_failed":
      const failedInvoice = event.data.object
      await handleInvoicePaymentFailure(failedInvoice)
      break

    default:
      console.log(`Unhandled event type ${event.type}`)
  }

  res.json({ received: true })
})

// Helper function to handle successful payments
async function handlePaymentSuccess(paymentIntent) {
  try {
    // Update payment intent status in Firestore
    await admin.firestore().collection("payment_intents").doc(paymentIntent.id).update({
      status: "succeeded",
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    })

    // Update invoice status if applicable
    if (paymentIntent.metadata.invoice_id) {
      await admin.firestore().collection("invoices").doc(paymentIntent.metadata.invoice_id).update({
        status: "paid",
        payment_intent_id: paymentIntent.id,
        paid_at: admin.firestore.FieldValue.serverTimestamp(),
      })
    }

    console.log("Payment succeeded:", paymentIntent.id)
  } catch (error) {
    console.error("Error handling payment success:", error)
  }
}

// Helper function to handle failed payments
async function handlePaymentFailure(paymentIntent) {
  try {
    // Update payment intent status in Firestore
    await admin.firestore().collection("payment_intents").doc(paymentIntent.id).update({
      status: "failed",
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    })

    console.log("Payment failed:", paymentIntent.id)
  } catch (error) {
    console.error("Error handling payment failure:", error)
  }
}

// Helper function to handle successful invoice payments
async function handleInvoicePaymentSuccess(invoice) {
  try {
    // Update Stripe invoice status in Firestore
    await admin.firestore().collection("stripe_invoices").doc(invoice.id).update({
      status: "paid",
      amount_paid: invoice.amount_paid,
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    })

    console.log("Invoice payment succeeded:", invoice.id)
  } catch (error) {
    console.error("Error handling invoice payment success:", error)
  }
}

// Helper function to handle failed invoice payments
async function handleInvoicePaymentFailure(invoice) {
  try {
    // Update Stripe invoice status in Firestore
    await admin.firestore().collection("stripe_invoices").doc(invoice.id).update({
      status: "payment_failed",
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    })

    console.log("Invoice payment failed:", invoice.id)
  } catch (error) {
    console.error("Error handling invoice payment failure:", error)
  }
}
