export default function (entries, onViewError) {
  entries.forEach((entry) => {
    let formData = new FormData();
    let { url, config } = entry.meta;
    formData.append("", entry.file, config.key);

    let xhr = new XMLHttpRequest();
    onViewError(() => xhr.abort());
    xhr.onload = () => {
      console.log(xhr.status);
      xhr.status < 300 ? entry.progress(100) : entry.error();
    };
    xhr.onerror = () => entry.error();
    xhr.upload.addEventListener("progress", (event) => {
      if (event.lengthComputable) {
        let percent = Math.round((event.loaded / event.total) * 100);
        if (percent < 100) {
          entry.progress(percent);
        }
      }
    });
    xhr.open("POST", url, true);
    xhr.setRequestHeader("Authorization", `Bearer ${config.access_token}`);
    xhr.send(formData);
  });
}
