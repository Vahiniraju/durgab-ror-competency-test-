module FlashHelper
  def bootstrap_alert(key)
    case key
    when 'alert'
      'warning'
    when 'notice'
      'info'
    when 'error'
      'danger'
    end
  end
end