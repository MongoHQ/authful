var handler = StripeCheckout.configure({
  key: 'pk_5KepSxyWPNcRaHdJzsxXircnQqZzr',
  image: "/square-image.png",
  token: function(token, args){
    console.log(token, args);
    document.getElementById("stripe-token").value = token;
    //document.getElementById("signup-form").submit();
  }
});

document.getElementById('checkout-button').addEventListener('click', function(e){
  handler.open({
    name: "MongoHQ",
    description: "Elastic Deployment ($18/GB)"
  });
  e.preventDefault();
});