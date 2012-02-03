var socket = io.connect('http://localhost'),
    $grid,
    $streamHead,
    $total;

socket.on('newUser', function(user){
    addFeedItem(user.text);
});

socket.on('tap', function(tap){
    addFeedItem(tap.text);
    $grid.find('.rfid' + tap.rfid).find('.number')
        .text(tap.wings).end().end()
        .isotope('updateSortData', $grid.find('li'))
        .isotope({ sortBy : 'wings' });
    $total.text(tap.total);
});

function addFeedItem(text){
    var $feedItem = $('<div/>', { 'class' : 'streamStory' })
        .text(text).css('display', 'none');

    $streamHead.after($feedItem);
    $feedItem.slideDown();
}

$(function(){
    $grid = $('.list');
    $streamHead = $('#streamHead');
    $total = $('#total');

    $grid.isotope({
        sortBy: 'wings',
        itemSelector: 'li',
        sortAscending : false,
        animationEngine : 'best-available',
        layoutMode: 'masonry',
        masonry: {
            columnWidth: 80
        },
        getSortData: {
            wings: function($el){
                return parseInt($el.find('.number').text(), 10);
            }
        }
    });

    setTimeout(function(){
       //$grid.isotope({ sortBy : 'wings' });
    }, 2000);

});