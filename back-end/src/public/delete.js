document.getElementById("deleteForm").addEventListener("submit", async (e) => {
  e.preventDefault();
  const form = e.target;
  const button = form.querySelector("button");
  button.disabled = true;
  button.innerText = "Submitting...";

  const data = {
    userId: form.userId.value,
    reason: form.reason.value,
  };

  try {
    const res = await fetch("https://safarworld.store/api/delete-account", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data),
    });

    const result = await res.json();

    if (res.ok) {
      document.getElementById("response").innerText =
        "✅ Your request has been submitted successfully.";
    } else {
      document.getElementById("response").innerText =
        "❌ Error: " + (result.error || "Something went wrong.");
    }
  } catch (err) {
    document.getElementById("response").innerText =
      "❌ Network error. Please try again.";
  } finally {
    button.disabled = false;
    button.innerText = "Submit Request";
  }
});
