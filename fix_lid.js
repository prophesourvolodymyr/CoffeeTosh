const fs = require('fs');
let content = fs.readFileSync('WEBSITE 2/animation.html', 'utf8');

// I will just replace the whole block of auto-detecting the close angle
// with a hardcoded logic that assumes the model is closed at 0, and opens to -1.9
// or +1.9. 
