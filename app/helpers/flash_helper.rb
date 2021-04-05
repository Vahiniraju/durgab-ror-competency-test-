module FlashHelper
  def bootstrap_alert(key)
    hash = { 'alert' => 'warning', 'notice' => 'info', 'error' => 'danger' }
    return hash[key] if hash[key]

    key
  end
end
