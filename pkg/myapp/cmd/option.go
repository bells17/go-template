package cmd

import "github.com/spf13/cobra"

type options struct {
	Debug bool // debug log level
}

func setOptions(cmd *cobra.Command, opt *options) {
	cmd.PersistentFlags().BoolVar(&opt.Debug, "debug", false, "log debug flag")
}
