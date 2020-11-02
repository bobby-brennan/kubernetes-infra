let fs = require('fs');

let albumFile = fs.readFileSync('./albums.csv', 'utf8');
let albums = albumFile.split('\n').filter(l => l).map(line => {
  let fields = line.split('\t');
  return {
    name: fields[1],
    id: fields[0],
    shortid: fields[2],
  }
});

const randomID = function() {
  return Math.floor(Math.random() * 10000).toString();
}

let photoFile = fs.readFileSync('./photos.csv', 'utf8');
let photos = photoFile.split('\n').filter(l => l).map(line => {
  let fields = line.split('\t');
  return {
    title: fields[1],
    filename: fields[3],
    second_filename: fields[18],
    album: fields[19],
    medium: fields[21],
  }
})

albums.push({
  name: 'Unsorted',
  id: '0',
  shortid: '0',
})

if (!fs.existsSync('./albums')) {
  fs.mkdirSync('./albums');
}

photos.forEach(photo => {
  console.log(photo);
  let album = albums.find(a => a.id === photo.album);
  if (!album) throw new Error("No album found");
  dir = './albums/' + album.name.replace(/\W+/g, "_");
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir);
  }
  outfile = dir + '/' + photo.title + '.jpg';
  while (fs.existsSync(outfile)) {
    outfile = dir + '/' + photo.title + '-' + randomID() + '.jpg';
  }
  try {
    fs.renameSync('./uploads/big/' + photo.filename, outfile);
  } catch (e) {
    console.log('falling back');
    fs.renameSync('./uploads/medium/' + photo.filename, outfile);
  }
});

console.log("moved", photos.length, "photos")
