# Wrapper class for GMC singletons that require references
# to the MPF global autoload. This class accepts the global
# as an argument so refs can be internalized.

class_name GMCCoreScriptNode
extends LoggingNode

var mpf: MPFGMC

func _init(mpf_gmc) -> void:
    self.mpf = mpf_gmc
