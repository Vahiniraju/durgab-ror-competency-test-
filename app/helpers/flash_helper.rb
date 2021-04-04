module FlashHelper
  def bootstrap_alert(key)
    hash = { 'alert' => 'warning', 'notice' => 'info', 'error' => 'danger' }
    hash[key]
  end
end
