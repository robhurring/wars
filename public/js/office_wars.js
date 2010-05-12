$.wars = {
  debug: true,
  quick_transactions: true,
  keyboard_shortcuts: true,
  paths: {
    buy: {
      product: '/product/%(id)d/buy/%(quantity)d',
      equipment: '/equipment/%(id)d/buy/%(quantity)d'
    },
    sell: {
      product: '/product/%(id)d/sell/%(quantity)d',
      equipment: '/equipment/%(id)d/sell/%(quantity)d'
    },
    bank: {
      deposit: '/bank/deposit/%(amount)d',
      withdrawl: '/bank/withdrawl/%(amount)d'
    },
    loan: {
      repay: '/loan/repay/%(amount)d',
      borrow: '/loan/borrow/%(amount)d'
    },
    fight: {
      attack: '/fight/attack',
      run: '/fight/run'
    },
    bulletins: {
      post: '/post_bulletin'
    }
  },
  messages: {
    buy: {
      product: "You're trying to buy <strong>%(name)s</strong> at <strong>$%(price)s</strong>. <br/>You can carry <strong>%(quantity)d</strong>, how many do you want?",
      equipment: "You're trying to buy &quot;<strong>%(name)s</strong>&quot; for <strong>$%(price)s</strong>. This adds %(amount)d %(adds)s. <br/>You can carry %(quantity)d more of these."
    },
    sell: {
      product: "You're trying to sell <strong>%(name)s</strong> at <strong>$%(sale_price)s</strong>. You will make <strong>$%(profit)s</strong> profit per item. <br/>How many do you want to sell?",
      equipment: "You're trying to sell <strong>%(name)s</strong> for <strong>$%(sale_price)s</strong>."
    }
  }  
};

$(function()
{
  
// App Setup

  $.metadata.setType('attr', 'data');
  
  $('textarea[maxlength]').live('keyup', function()
  {
		var max = parseInt($(this).attr('maxlength'));

		if($(this).val().length > max)
			$(this).val($(this).val().substr(0, $(this).attr('maxlength')));

		$(this).parent().find('.character_counter').html(max - $(this).val().length);
	});
	
  
// KeyBindings

  if($.wars.keyboard_shortcuts)
  {
    $(document).keypress(function(event)
    {
      var code = event.charCode;
      if(code < 97) code += 32; // bring us on up
      if(code == 98 /* "b" */) $('#buyable').focus();
      if(code == 115 /* "s" */) $('#sellable').focus();
      if(code == 97 /* "a" */) location = $.wars.paths.fight.attack;
      if(code == 114 /* "r" */) location = $.wars.paths.fight.run;
    });

    $('#buyable').live('keypress', function(){ $(this).click(); });
    $('#sellable').live('keypress', function(){ $(this).click(); }); 
  }
  
// Transactions

  if($.wars.quick_transactions)
  {
    $('#buyable').live('dblclick', function(){
      setup_transaction(this);
      preform_transaction();
    });
    $('#sellable').live('dblclick', function(){
      setup_transaction(this);
      preform_transaction();
    });
  }

  $('#buyable').live('click', function(){ setup_transaction(this); });
  $('#sellable').live('click', function(){ setup_transaction(this); });
  
  $('#transaction_submit').live('click', function(){ preform_transaction(); });
  $('#transaction_quantity').live('keypress', function(event){ if(event.charCode == 13) preform_transaction(); });

// Bulletins

  $('#bulletin_message').focus();
  $('#post_bulletin').live('click', function()
  {
    var message = $('#bulletin_message').val();
    restage($.wars.paths.bulletins.post, {"message": message})
    return false;
  });

// Bank & Loans

  $('#amount').focus();
  $('#amount').select();

  $('#bank_deposit').live('click', function()
  {
    var amount = parseInt($('#amount').val());
    var path = $.sprintf($.wars.paths.bank.deposit, {amount: amount});
    restage(path);
    return false;
  });
  
  $('#bank_withdrawl').live('click', function()
  {
    var amount = parseInt($('#amount').val());
    var path = $.sprintf($.wars.paths.bank.withdrawl, {amount: amount});
    restage(path);
    return false;
  });

  $('#loan_repay').live('click', function()
  {
    var amount = parseInt($('#amount').val());
    var path = $.sprintf($.wars.paths.loan.repay, {amount: amount});
    restage(path);
    return false;
  });
  
  $('#loan_borrow').live('click', function()
  {
    var amount = parseInt($('#amount').val());
    var path = $.sprintf($.wars.paths.loan.borrow, {amount: amount});
    restage(path);
    return false;
  });
  
// Destructive Links

  $('.destructive').click(function()
  {
    var message = $(this).metadata().message || 'Are you sure?';
    return confirm(message);
  });

});

function restage(path, data)
{
  if(!path) return;
  
  $('#stage').loading({align: 'center', mask: true, img: '/images/indicator.gif'});
  $('#stage').load(path, (data || {}), function(){
    $('#stage').loading();
  });  
}

function preform_transaction()
{
  if(arguments.length == 4)
  {
    var id = arguments[0];
    var quantity = arguments[1];
    var buying = arguments[2];
    var is_product = arguments[3];
  }else{
    var id = parseInt($('#transaction_id').val());
    var quantity = parseInt($('#transaction_quantity').val());
    var buying = ($('#transaction_type').val() == 'buy');
    var is_product = ($('#transaction_is_product').val() == 1);
  }
  
  debug({id: id, quantity: quantity, buying: buying, is_product: is_product});
  
  if(parseInt(quantity) <= 0 || (buying && !id))
    return false;

  var format = $.wars.paths[(buying ? 'buy' : 'sell')][(is_product ? 'product' : 'equipment')];
  var path = $.sprintf(format, {id: parseInt(id), quantity: parseInt(quantity)});
  
  restage(path, {});
}

// Sets up the transaction form and all that jazz for products & equipment purchasing/selling
function setup_transaction(select)
{
  var select = $(select);
  var option = $(select.attr('options')[select.attr('selectedIndex')]);
  var item_id = option.val();
  var buying = select.metadata().buying;
  var is_product = (select.metadata().products ? 1 : 0);
  var quantity = parseInt(option.metadata().quantity);
  if(quantity < 0) quantity = 0;  
  
  // Setup details
  var format = $.wars.messages[(buying ? 'buy' : 'sell')][(is_product ? 'product' : 'equipment')];
  $('#transaction_details').html($.sprintf(format, option.metadata()));
  $('#transaction_submit').val('Buy!');
  
  // Setup form
  $('#transaction').show();
  $('#transaction_id').val(item_id);
  $('#transaction_type').val((buying ? 'buy' : 'sell'));
  $('#transaction_is_product').val(is_product);
  $('#transaction_quantity').val(quantity);
  $('#transaction_submit').val((buying ? 'Buy!' : 'Sell!'));
  $('#transaction_quantity').focus();
  $('#transaction_quantity').select();

  if(quantity <= 0)
    $('#transaction_fields').hide();  
  else
    $('#transaction_fields').show();
}

function debug(msg)
{
  if(typeof(console) !== 'undefined' && console != null && $.wars.debug)
    console.log(msg);
}