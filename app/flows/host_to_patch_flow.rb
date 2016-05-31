class HostToPatchFlow < ActiveFlow::Base
  def self.create(in_port:)
    send_flow_mod_add(0xdad1c001,
                      match: Match.new(in_port: in_port),
                      actions: SendOutPort.new(Vhost.all.size + 1))
  end

  def self.destroy(in_port:)
    send_flow_mod_delete(0xdad1c001,
                         match: Match.new(in_port: in_port),
                         out_port: Vhost.all.size + 1)
  end

  def self.all
    flow_stats(0xdad1c001).stats.select do |each|
      each.actions.size == 1 && each.actions.first.port == Vhost.all.size + 1
    end
  end
end
