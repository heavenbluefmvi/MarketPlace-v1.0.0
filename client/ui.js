// client/html/ui.js
// Thêm vào phần script của UI
window.addEventListener('message', (event) => {
    if (event.data.type === 'open') {
        initializeMarket(event.data.items, event.data.prices);
    } else if (event.data.type === 'updatePrices') {
        updatePrices(event.data.prices);
    }
});

function initializeMarket(items, prices) {
    // Khởi tạo bảng với dữ liệu từ server
}

function updatePrices(newPrices) {
    // Cập nhật giá và % thay đổi
}

function sellItems() {
    const itemsToSell = {};
    document.querySelectorAll('input[type="number"]').forEach(input => {
        if (input.value > 0) {
            const item = input.getAttribute('data-item');
            itemsToSell[item] = parseInt(input.value);
        }
    });
    
    fetch(`https://qb-market/sellItems`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(itemsToSell)
    });
}
