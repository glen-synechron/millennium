$(".categories").live("change",function(){
    //$(".dvLoading").show();
    $.ajax({
        url: '/search/sub_categories',
        type : "GET",
        data : {category_id: $(this).val()},
        success: function(data) {
            //$(".dvLoading").hide();
        }
    });
});

$(".search-free-slots").live("click",function(){
    if($("#search_service").val()!="" && $("#search_date").val()!="" && $("#search_service").val()!="")
     {
      $("#search_free_slots_form").submit();
      $(".dvLoading").show();
     }
     else{
      alert("Please select date and time value")
    }
});

$(".get-price").live("change",function(){
    $(".dvLoading").show();
    $.ajax({
        url: '/appointments/check_price',
        type : "GET",
        data : {service_id: $("#appointment_service").val(),
                emp_id: $("#appointment_employee").val()
                },
        success: function(data) {
            $(".dvLoading").hide();
        }
    });
});