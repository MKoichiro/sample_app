// 10MB 以上の画像のアップロードをアラートで防止
document.addEventListener("turbo:load", () => {

  document.addEventListener("change", e => {
    let imageUpload = document.querySelector("#micropost_image");
    if (imageUpload && imageUpload.files.length > 0) {
      const sizeInMegabytes = imageUpload.files[0].size / 1024 / 1024;
      if (sizeInMegabytes > 10) {
        alert("Maximum file size is 10MB. Please choose a smaller file.");
        imageUpload.value = "";
      }
    }
  });

});
