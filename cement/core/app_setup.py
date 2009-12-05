
import os
from pkg_resources import get_distribution

from cement.core.log import setup_logging
from cement.core.options import init_parser, parse_options
from cement.core.config import set_config_opts_per_file
from cement.core.options import set_config_opts_per_cli_opts
from cement.core.exc import CementConfigError

def lay_cement(config, version_banner=None):
    validate_config(config)
    
    if not version_banner:
        version_banner = get_distribution(config['app_module']).version
        
    config = set_config_opts_per_file(config, config['app_module'], 
                                      config['config_file'])
    options = init_parser(config, version_banner)
    (config, cli_opts, cli_args) = parse_options(config, options)
    config = set_config_opts_per_cli_opts(config, cli_opts)
    setup_logging(config)
    return (config, cli_opts, cli_args)


def validate_config(config):
    """
    Validate that all required cement configuration options are set.
    """
    required_settings = [
        'config_source', 'config_file', 'debug', 'datadir',
        'enabled_plugins', 'plugin_config_dir', 'plugin_dir', 
        'plugins', 'app_module', 'app_name', 'tmpdir'
        ]
    for s in required_settings:
        if not config.has_key(s):
            raise CementConfigError, "config['%s'] value missing!" % s
    
    # create all directories if missing
    for d in [os.path.dirname(config['log_file']), config['datadir'], 
              config['plugin_config_dir'], config['plugin_dir'], 
              config['tmpdir']]:
        if not os.path.exists(d):
            os.makedirs(d)
            
            
def load_plugin(config, options, plugin):
    if config['show_plugin_load']:
        print 'loading %s plugin' % plugin
    full_plugin = '%s.plugins.%s' % (config['app_name'], plugin)
    import_string = "import %s" % config['app_name']
    try:
        exec(import_string)
    except ImportError, e:
        raise CementConfigError, '%s unable to import base app!' % config['app_name']
        
    # try from 'app_name' first, then cement name space    
    import_string = "from %s.plugins import %s" % (config['app_name'], plugin)
    try:
        exec(import_string)
        setup_string = "res = %s.plugins.%s.register(config, options)" % \
            (config['app_name'], plugin)
        module_path = '%s.plugins.%s' % (config['app_name'], plugin)
    except ImportError, e:
        try:
            import_string = "from cement.plugins import %s" % plugin
            exec(import_string)
            setup_string = "res = cement.plugins.%s.register(config, options)" % \
                plugin
            module_path = 'cement.plugins.%s' % plugin
        except ImportError, e:
            raise cementConfigError, \
                'failed to load %s plugin: %s' % (plugin, e)    
    exec(setup_string)

    (plugin_config, plugin_commands, plugin_exposed, options) = res
    plugin_config_file = os.path.join(
        config['plugin_config_dir'], '%s.plugin' % plugin
        )
    plugin_config = set_config_opts_per_file(
        plugin_config, plugin, plugin_config_file
        )

    # update the config
    config['plugin_configs'][full_plugin] = plugin_config
        
    # handler hook
    try:
        handler_string = "handler = %s.get_handler_hook(config)" % module_path
        exec(handler_string)
    except AttributeError, e:
        handler = None
        
    return (config, plugin_commands, plugin_exposed, options, handler)
    
    
def load_plugins(config, options, handlers):
    p = config['enabled_plugins'][:] # make a copy
    all_plugin_commands = {}
    all_plugin_exposed = {}
                
    for plugin in p:
        full_plugin = '%s.plugins.%s' % (config['app_name'], plugin)
        res = load_plugin(config, options, plugin)
        (config, plugin_commands, plugin_exposed, options, handler) = res
        all_plugin_commands.update(plugin_commands)
        if len(plugin_exposed) > 0:
            all_plugin_exposed[full_plugin] = plugin_exposed
        if handler:
            if handler[0] in handlers:
                raise ShakedownPluginError, 'handler[%s] already provided by %s' % \
                    (handler[0], handlers[handler[0]].__module__)
            handlers[handler[0]] = handler[1]
    return (config, all_plugin_commands, all_plugin_exposed, options, handlers)