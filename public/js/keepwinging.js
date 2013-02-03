var socket = io.connect('http://localhost'),
    $grid,
    $streamHead,
    $total,
    $select,
    displayMode = 'all',
    totals = {},
    $totals = {},
    metrics = ['all', 'wings', 'beer', 'brownies'];

socket.on('newUser', function(user){
    addFeedItem(user.text);
});

socket.on('tap', function(tap){
    addFeedItem(tap.text);

    var $user = $grid.find('.rfid' + tap.rfid),
        foodTotal = parseInt($user.attr('data-' + tap.food), 10),
        allTotal = parseInt($user.attr('data-all'), 10);

    $user.attr('data-' + tap.food, foodTotal += tap.num);
    $user.attr('data-all', allTotal += tap.num);
    if(displayMode === tap.food){
        $user.find('.number').text(foodTotal);
    }else if(displayMode === 'all'){
        $user.find('.number').text(allTotal);
    }
    $grid.isotope('updateSortData', $grid.find('li'))
        .isotope({ sortBy : displayMode });

    var total = totals[tap.food] += tap.num;
    totals.all += tap.num;
    $totals[tap.food].text(total);
    $totals.all.text(totals.all);

});

function addFeedItem(text){
    var $feedItem = $('<div/>', { 'class' : 'streamStory' })
        .text(text).css('display', 'none');

    $streamHead.after($feedItem);
    $feedItem.slideDown();
}

var sortFunctions = (function(){
    var functions = {};
    for(var i = 0, l = metrics.length; i < l; i++){
        (function(metric){
            functions[metric] = function($el){
                return parseInt($el.attr('data-' + metric), 10);
            }
        })(metrics[i]);
    }
    return functions;
})();


$(function(){
    $grid = $('.list');
    $streamHead = $('#streamHead');
    for(var i = 0, l = metrics.length; i < l; i++){
        $totals[metrics[i]] = $('#total-' + metrics[i]);
        totals[metrics[i]] = parseInt($totals[metrics[i]].text(), 10);
    }

    $select = $('#metric-select').on('change', function(){
        displayMode = $select.val();
        var $lis = $grid.find('li');
        $lis.each(function(){
            var $this = $(this);
            $this.find('.number').text($this.attr('data-' + displayMode));
        });
        $grid.isotope('updateSortData', $lis)
            .isotope({ sortBy : displayMode });
    });

    $grid.isotope({
        sortBy: 'all',
        itemSelector: 'li',
        sortAscending : false,
        animationEngine : 'best-available',
        layoutMode: 'masonry',
        masonry: {
            columnWidth: 80
        },
        getSortData: sortFunctions
    });

});