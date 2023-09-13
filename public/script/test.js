function myFunction() {
  var input, filter, ul, li, a, i;
  input = document.getElementById("mySearch");
  filter = input.value.toUpperCase();
  ul = document.getElementById("myMenu");
  li = ul.getElementsByTagName("li");
  for (i = 0; i < li.length; i++) {
    a = li[i].getElementsByTagName("a")[0];
    if (a.innerHTML.toUpperCase().indexOf(filter) > -1) {
      li[i].style.display = "";
    } else {
      li[i].style.display = "none";
    }
  }
}
// show possible templates
function showOptions(){
        /* show light box*/
       var small_img = document.getElementById("canvas");
        var big_img = document.getElementById("light_image");
        big_img.src = small_img.src;
        big_img.alt = small_img.alt;
        big_img.style.display = "block";
        document.getElementById("dark_overlay").style.display = "block";
}

function showFlower(event){  
 // Load and draw the image
  const image = new Image();
  image.src = '/images/flower.png';
  image.onload = function () {
    const scale = Math.min(canvas.width / image.width, canvas.height / image.height);
    const width = image.width * scale;
    const height = image.height * scale;
    const x = (canvas.width - width) / 2;
    const y = (canvas.height - height) / 2;

    ctx.drawImage(image, x, y, width, height);
  };
}
  
function showAirplane(event){
   // Load and draw the image
  const image = new Image();
  image.src = '/images/airplane.png';
  image.onload = function () {
    const scale = Math.min(canvas.width / image.width, canvas.height / image.height);
    const width = image.width * scale;
    const height = image.height * scale;
    const x = (canvas.width - width) / 2;
    const y = (canvas.height - height) / 2;

    ctx.drawImage(image, x, y, width, height);
  };
}

function showLightbulb(event){  
 // Load and draw the image
  const image = new Image();
  image.src = '/images/lightbulb.png';
  image.onload = function () {
    const scale = Math.min(canvas.width / image.width, canvas.height / image.height);
    const width = image.width * scale;
    const height = image.height * scale;
    const x = (canvas.width - width) / 2;
    const y = (canvas.height - height) / 2;

    ctx.drawImage(image, x, y, width, height);
  };
}

function showWeather(event){  
 // Load and draw the image
  const image = new Image();
  image.src = '/images/weather.png';
  image.onload = function () {
    const scale = Math.min(canvas.width / image.width, canvas.height / image.height);
    const width = image.width * scale;
    const height = image.height * scale;
    const x = (canvas.width - width) / 2;
    const y = (canvas.height - height) / 2;

    ctx.drawImage(image, x, y, width, height);
  };
}

function showDrink(event){  
 // Load and draw the image
  const image = new Image();
  image.src = '/images/drink.png';
  image.onload = function () {
    const scale = Math.min(canvas.width / image.width, canvas.height / image.height);
    const width = image.width * scale;
    const height = image.height * scale;
    const x = (canvas.width - width) / 2;
    const y = (canvas.height - height) / 2;

    ctx.drawImage(image, x, y, width, height);
  };
}

function showBus(event){  
 // Load and draw the image
  const image = new Image();
  image.src = '/images/bus.png';
  image.onload = function () {
    const scale = Math.min(canvas.width / image.width, canvas.height / image.height);
    const width = image.width * scale;
    const height = image.height * scale;
    const x = (canvas.width - width) / 2;
    const y = (canvas.height - height) / 2;

    ctx.drawImage(image, x, y, width, height);
  };
}

function showButterfly(event){  
 // Load and draw the image
  const image = new Image();
  image.src = '/images/butterfly.png';
  image.onload = function () {
    const scale = Math.min(canvas.width / image.width, canvas.height / image.height);
    const width = image.width * scale;
    const height = image.height * scale;
    const x = (canvas.width - width) / 2;
    const y = (canvas.height - height) / 2;

    ctx.drawImage(image, x, y, width, height);
  };
}
function showCamera(event){  
 // Load and draw the image
  const image = new Image();
  image.src = '/images/camera.png';
  image.onload = function () {
    const scale = Math.min(canvas.width / image.width, canvas.height / image.height);
    const width = image.width * scale;
    const height = image.height * scale;
    const x = (canvas.width - width) / 2;
    const y = (canvas.height - height) / 2;

    ctx.drawImage(image, x, y, width, height);
  };
}

function showCar(event){  
 // Load and draw the image
  const image = new Image();
  image.src = '/images/car.png';
  image.onload = function () {
    const scale = Math.min(canvas.width / image.width, canvas.height / image.height);
    const width = image.width * scale;
    const height = image.height * scale;
    const x = (canvas.width - width) / 2;
    const y = (canvas.height - height) / 2;

    ctx.drawImage(image, x, y, width, height);
  };
}
function showSun(event){  
 // Load and draw the image
  const image = new Image();
  image.src = '/images/sun.png';
  image.onload = function () {
    const scale = Math.min(canvas.width / image.width, canvas.height / image.height);
    const width = image.width * scale;
    const height = image.height * scale;
    const x = (canvas.width - width) / 2;
    const y = (canvas.height - height) / 2;

    ctx.drawImage(image, x, y, width, height);
  };
}

function showDesign(event){  
 // Load and draw the image
  const image = new Image();
  image.src = '/images/design.png';
  image.onload = function () {
    const scale = Math.min(canvas.width / image.width, canvas.height / image.height);
    const width = image.width * scale;
    const height = image.height * scale;
    const x = (canvas.width - width) / 2;
    const y = (canvas.height - height) / 2;

    ctx.drawImage(image, x, y, width, height);
  };
}

function showEarth(event){  
 // Load and draw the image
  const image = new Image();
  image.src = '/images/earth.png';
  image.onload = function () {
    const scale = Math.min(canvas.width / image.width, canvas.height / image.height);
    const width = image.width * scale;
    const height = image.height * scale;
    const x = (canvas.width - width) / 2;
    const y = (canvas.height - height) / 2;

    ctx.drawImage(image, x, y, width, height);
  };
}

function showPhone(event){  
 // Load and draw the image
  const image = new Image();
  image.src = '/images/phone.png';
  image.onload = function () {
    const scale = Math.min(canvas.width / image.width, canvas.height / image.height);
    const width = image.width * scale;
    const height = image.height * scale;
    const x = (canvas.width - width) / 2;
    const y = (canvas.height - height) / 2;

    ctx.drawImage(image, x, y, width, height);
  };
}

function showBells(event){  
 // Load and draw the image
  const image = new Image();
  image.src = '/images/bells.png';
  image.onload = function () {
    const scale = Math.min(canvas.width / image.width, canvas.height / image.height);
    const width = image.width * scale;
    const height = image.height * scale;
    const x = (canvas.width - width) / 2;
    const y = (canvas.height - height) / 2;

    ctx.drawImage(image, x, y, width, height);
  };
}

function showPig(event){  
 // Load and draw the image
  const image = new Image();
  image.src = '/images/pig.png';
  image.onload = function () {
    const scale = Math.min(canvas.width / image.width, canvas.height / image.height);
    const width = image.width * scale;
    const height = image.height * scale;
    const x = (canvas.width - width) / 2;
    const y = (canvas.height - height) / 2;

    ctx.drawImage(image, x, y, width, height);
  };
}

function showShip(event){  
 // Load and draw the image
  const image = new Image();
  image.src = '/images/ship.png';
  image.onload = function () {
    const scale = Math.min(canvas.width / image.width, canvas.height / image.height);
    const width = image.width * scale;
    const height = image.height * scale;
    const x = (canvas.width - width) / 2;
    const y = (canvas.height - height) / 2;

    ctx.drawImage(image, x, y, width, height);
  };
}