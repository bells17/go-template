package cmd

import (
	"fmt"
	"os"

	"github.com/sirupsen/logrus"
	"github.com/spf13/cobra"

	"github.com/bells17/go-template/pkg/version"
)

func NewCommand() *cobra.Command {
	opt := &options{}
	cmd := &cobra.Command{
		Use:   "myapp",
		Short: "myapp",
		Run: func(cmd *cobra.Command, args []string) {
			d := NewRuntime()
			d.Run(opt)
		},
	}

	setOptions(cmd, opt)

	cmd.AddCommand(&cobra.Command{
		Use:   "version",
		Short: "Print the version number",
		Run: func(cmd *cobra.Command, args []string) {
			fmt.Printf("%s info: %s\n", version.Version(), version.VersionInfo())
		},
	})

	return cmd
}

type Runtime struct{}

func NewRuntime() *Runtime {
	return &Runtime{}
}

func (a *Runtime) Run(opt *options) {
	l := newLogger(opt.Debug)
	log := l.WithFields(logrus.Fields{"type": "entrypoint"})
	log.Info()
	fmt.Print("Run myapp!")
}

func newLogger(isDebug bool) *logrus.Logger {
	log := logrus.New()
	log.SetFormatter(&logrus.JSONFormatter{})
	log.SetOutput(os.Stdout)

	if isDebug {
		log.SetReportCaller(true)
		log.SetLevel(logrus.DebugLevel)
	} else {
		log.SetLevel(logrus.InfoLevel)
	}

	return log
}
